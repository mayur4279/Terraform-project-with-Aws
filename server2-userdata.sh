#!/bin/bash
yum update
yum install -y httpd  


# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Mayur's Website</title>
  <style>
    /* Add animation and styling for the text */
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }
    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>
<body>
  <h1>Terraform Project Server 2</h1>
  <h2>Welcome You !! </h2>
 
  
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start httpd
systemctl enable httpd  


