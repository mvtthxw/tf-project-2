<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>App Fargate</title>
</head>
<body>
    <h1>Param Store V1</h1>
    <h1>Hello from App Fargate v1.0.0</h1>
    <p>Container: <?= htmlspecialchars(gethostname()) ?></p>
    <p>Param Store:
        <?php
        $paramStore = getenv('PARAMS_STORE');
        if ($paramStore) {
            echo htmlspecialchars($paramStore);
        } else {
            echo '<i>not set</i>';
        }
        ?>
    </p>
</body>
</html>
