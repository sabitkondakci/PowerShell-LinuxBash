$Username="******@gmail.com";
$Password="+++++++";
$email="******@gmail.com";

$message = new-object Net.Mail.MailMessage;
$message.From = "****@gmail.com";
$message.To.Add($email);
$message.Subject = "Sending email from PowerShell";
$message.Body = "Hey, It worked!";
$smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
$smtp.EnableSsl=$true;
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.SendMailAsync($message);
