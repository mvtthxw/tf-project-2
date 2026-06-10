<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>App Fargate</title>
</head>
<body>
    <h1>Time App</h1>
    <h1>Hello from App Fargate <?= htmlspecialchars(is_readable('/etc/app/version') ? trim(file_get_contents('/etc/app/version')) : 'dev') ?></h1>
    <p>Container: <?= htmlspecialchars(gethostname()) ?></p>
    <p>Time: <?= date('H:i:s') ?></p>
</body>
</html>
