const String authCallbackHtml = '''
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>BookVerse - Login Berhasil</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: linear-gradient(135deg, #6750A4, #7C6BC0);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
  }
  .card {
    background: white;
    border-radius: 20px;
    padding: 48px 40px;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.15);
    max-width: 400px;
    width: 100%;
  }
  .icon { font-size: 64px; margin-bottom: 16px; }
  h1 { color: #1a1a2e; font-size: 24px; margin-bottom: 8px; }
  p { color: #666; font-size: 15px; line-height: 1.6; margin-bottom: 32px; }
  .btn {
    background: #6750A4;
    color: white;
    border: none;
    padding: 14px 32px;
    border-radius: 100px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }
  .btn:hover { background: #7C6BC0; }
  .badge {
    display: inline-block;
    background: #E8E0F0;
    color: #6750A4;
    padding: 6px 16px;
    border-radius: 100px;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 16px;
  }
</style>
</head>
<body>
<div class="card">
  <div class="icon">📖</div>
  <span class="badge">BookVerse</span>
  <h1>Login Berhasil!</h1>
  <p>Akun Google kamu sudah terhubung.<br>Silakan tutup tab ini dan kembali ke aplikasi.</p>
  <button class="btn" onclick="window.close()">Tutup Tab Ini</button>
</div>
<script>setTimeout(() => window.close(), 3000);</script>
</body>
</html>
''';
