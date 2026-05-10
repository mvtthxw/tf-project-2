<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>App Managed</title>
</head>
<body>
    <h1>Time App V1</h1>
    <h1>Hello from App Managed v1.0.0</h1>
    <p>Container: <?= htmlspecialchars(gethostname()) ?></p>
    <p>Time: <?= date('H:i:s') ?></p>
</body>
</html>
