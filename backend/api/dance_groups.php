<?php
// REST API for the dance_groups table.
//
// GET    dance_groups.php         -> list all (newest first)
// GET    dance_groups.php?id=1    -> get one
// POST   dance_groups.php         -> create (JSON body)
// PUT    dance_groups.php?id=1    -> update (JSON body)
// DELETE dance_groups.php?id=1    -> delete
//
// Fallback for hosts that block PUT/DELETE:
// POST with {"_method": "PUT"} or {"_method": "DELETE"} in the JSON body.

require_once __DIR__ . '/../config/db.php';

const DANCE_STYLES = ['Folk', 'Festival', 'Street', 'Contemporary', 'Cultural', 'Ballroom'];

// ---------- Read the request ----------

$method = $_SERVER['REQUEST_METHOD'];

// Read the JSON body (empty for GET and DELETE).
$rawBody = file_get_contents('php://input');
$body = [];
if ($rawBody !== '' && $rawBody !== false) {
    $body = json_decode($rawBody, true);
    if (!is_array($body)) {
        sendJson(400, false, 'Request body must be valid JSON.');
    }
}

// Method override: POST + "_method" acts like PUT or DELETE.
if ($method === 'POST' && isset($body['_method'])) {
    $override = strtoupper((string) $body['_method']);
    if (in_array($override, ['PUT', 'DELETE'], true)) {
        $method = $override;
    }
}

// The id comes from the URL (?id=5). null means "no id given".
$id = null;
if (isset($_GET['id'])) {
    $id = filter_var($_GET['id'], FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    if ($id === false) {
        sendJson(400, false, 'The id must be a positive whole number.');
    }
}

// ---------- Helpers ----------

// Converts a database row into clean JSON types (numbers and booleans).
function formatRow(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'group_name' => $row['group_name'],
        'dance_style' => $row['dance_style'],
        'region' => $row['region'],
        'city' => $row['city'],
        'founded_year' => $row['founded_year'] === null ? null : (int) $row['founded_year'],
        'member_count' => (int) $row['member_count'],
        'leader_name' => $row['leader_name'],
        'signature_dance' => $row['signature_dance'],
        'description' => $row['description'],
        'is_active' => (bool) $row['is_active'],
        'created_at' => $row['created_at'],
    ];
}

function findGroup(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM dance_groups WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    return $row ? formatRow($row) : null;
}

// Trims a text value. Empty text becomes null (for optional fields).
function cleanText($value): ?string
{
    if ($value === null) {
        return null;
    }
    $text = trim((string) $value);
    return $text === '' ? null : $text;
}

// Validates the input with the SAME rules as the Flutter form.
// Returns [cleanData, errors]. errors is empty when everything is valid.
function validateGroup(array $in): array
{
    $errors = [];
    $currentYear = (int) date('Y');

    $groupName = cleanText($in['group_name'] ?? null);
    if ($groupName === null) {
        $errors['group_name'] = 'Group name is required.';
    } elseif (mb_strlen($groupName) < 2 || mb_strlen($groupName) > 100) {
        $errors['group_name'] = 'Group name must be 2 to 100 characters.';
    }

    $danceStyle = cleanText($in['dance_style'] ?? null);
    if ($danceStyle === null) {
        $errors['dance_style'] = 'Dance style is required.';
    } elseif (!in_array($danceStyle, DANCE_STYLES, true)) {
        $errors['dance_style'] = 'Dance style must be one of: ' . implode(', ', DANCE_STYLES) . '.';
    }

    $region = cleanText($in['region'] ?? null);
    if ($region === null) {
        $errors['region'] = 'Region is required.';
    } elseif (mb_strlen($region) > 50) {
        $errors['region'] = 'Region must be at most 50 characters.';
    }

    $city = cleanText($in['city'] ?? null);
    if ($city === null) {
        $errors['city'] = 'City is required.';
    } elseif (mb_strlen($city) > 80) {
        $errors['city'] = 'City must be at most 80 characters.';
    }

    // Optional: empty means "unknown".
    $foundedYear = null;
    $yearInput = cleanText($in['founded_year'] ?? null);
    if ($yearInput !== null) {
        $foundedYear = filter_var($yearInput, FILTER_VALIDATE_INT);
        if ($foundedYear === false || $foundedYear < 1900 || $foundedYear > $currentYear) {
            $errors['founded_year'] = "Founded year must be between 1900 and $currentYear.";
        }
    }

    $memberCount = filter_var($in['member_count'] ?? null, FILTER_VALIDATE_INT);
    if ($memberCount === false || $memberCount === null || $memberCount < 1 || $memberCount > 500) {
        $errors['member_count'] = 'Member count must be a whole number from 1 to 500.';
    }

    $leaderName = cleanText($in['leader_name'] ?? null);
    if ($leaderName !== null && mb_strlen($leaderName) > 100) {
        $errors['leader_name'] = 'Leader name must be at most 100 characters.';
    }

    $signatureDance = cleanText($in['signature_dance'] ?? null);
    if ($signatureDance !== null && mb_strlen($signatureDance) > 100) {
        $errors['signature_dance'] = 'Signature dance must be at most 100 characters.';
    }

    // Missing is_active defaults to active. Accepts true/false, 1/0, "1"/"0".
    $isActive = filter_var($in['is_active'] ?? true, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
    if ($isActive === null) {
        $errors['is_active'] = 'is_active must be true or false.';
    }

    $clean = [
        'group_name' => $groupName,
        'dance_style' => $danceStyle,
        'region' => $region,
        'city' => $city,
        'founded_year' => $foundedYear,
        'member_count' => $memberCount,
        'leader_name' => $leaderName,
        'signature_dance' => $signatureDance,
        'description' => cleanText($in['description'] ?? null),
        'is_active' => $isActive ? 1 : 0,
    ];

    return [$clean, $errors];
}

// ---------- Handle the request ----------

$db = getDb();

try {
    switch ($method) {
        case 'GET':
            if ($id === null) {
                $rows = $db->query('SELECT * FROM dance_groups ORDER BY created_at DESC, id DESC')->fetchAll();
                sendJson(200, true, 'Dance groups loaded.', array_map('formatRow', $rows));
            }
            $group = findGroup($db, $id);
            if ($group === null) {
                sendJson(404, false, 'Dance group not found.');
            }
            sendJson(200, true, 'Dance group loaded.', $group);
            break;

        case 'POST':
            [$data, $errors] = validateGroup($body);
            if ($errors) {
                sendJson(422, false, 'Please fix the highlighted fields.', $errors);
            }
            $stmt = $db->prepare(
                'INSERT INTO dance_groups
                   (group_name, dance_style, region, city, founded_year, member_count,
                    leader_name, signature_dance, description, is_active)
                 VALUES
                   (:group_name, :dance_style, :region, :city, :founded_year, :member_count,
                    :leader_name, :signature_dance, :description, :is_active)'
            );
            $stmt->execute($data);
            $newGroup = findGroup($db, (int) $db->lastInsertId());
            sendJson(201, true, 'Dance group created.', $newGroup);
            break;

        case 'PUT':
            if ($id === null) {
                sendJson(400, false, 'Missing id. Use dance_groups.php?id=1');
            }
            if (findGroup($db, $id) === null) {
                sendJson(404, false, 'Dance group not found.');
            }
            [$data, $errors] = validateGroup($body);
            if ($errors) {
                sendJson(422, false, 'Please fix the highlighted fields.', $errors);
            }
            $data['id'] = $id;
            $stmt = $db->prepare(
                'UPDATE dance_groups SET
                   group_name = :group_name, dance_style = :dance_style, region = :region,
                   city = :city, founded_year = :founded_year, member_count = :member_count,
                   leader_name = :leader_name, signature_dance = :signature_dance,
                   description = :description, is_active = :is_active
                 WHERE id = :id'
            );
            $stmt->execute($data);
            sendJson(200, true, 'Dance group updated.', findGroup($db, $id));
            break;

        case 'DELETE':
            if ($id === null) {
                sendJson(400, false, 'Missing id. Use dance_groups.php?id=1');
            }
            $stmt = $db->prepare('DELETE FROM dance_groups WHERE id = ?');
            $stmt->execute([$id]);
            if ($stmt->rowCount() === 0) {
                sendJson(404, false, 'Dance group not found.');
            }
            sendJson(200, true, 'Dance group deleted.', ['id' => $id]);
            break;

        default:
            sendJson(405, false, 'Method not allowed. Use GET, POST, PUT, or DELETE.');
    }
} catch (PDOException $e) {
    // Log the details for the developer, but show only a generic message.
    error_log('Database error: ' . $e->getMessage());
    sendJson(500, false, 'A database error occurred. Please try again later.');
}
