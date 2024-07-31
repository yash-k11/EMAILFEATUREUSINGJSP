<%@ page import="java.util.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.sql.*" %>
<html>
<head>    
    <title> Subscribe App </title>
    
       <style>
    * {
        font-size: 30px;
    }
    body {
        background-color: azure;
    }
    h1 {
        background-color: black;
        color: white;
        width: 50%;
        border-radius: 30px;
        padding: 20px;
    }
    input[type="email"] {
        width: 100%; /* Full width */
        max-width: 500px; /* Max width */
        height: 50px;
        font-size: 24px;
        padding: 10px;
        margin: 10px 0;
        border: 2px solid #ccc;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        transition: border-color 0.3s, box-shadow 0.3s;
    }
    input[type="email"]:focus {
        border-color: #007BFF; /* Focus border color */
        box-shadow: 0 0 8px rgba(0, 123, 255, 0.2);
        outline: none;
    }
    input[type="submit"] {
        font-size: 24px;
        padding: 10px 20px;
        border: none;
        border-radius: 8px;
        color: white;
        background-color: #007BFF;
        cursor: pointer;
        transition: background-color 0.3s, transform 0.3s;
    }
    input[type="submit"]:hover {
        background-color: #0056b3; /* Darker shade on hover */
        transform: scale(1.05); /* Slightly enlarge on hover */
    }
    input[type="submit"]:active {
        background-color: #00408b; /* Even darker shade on click */
        transform: scale(1); /* Reset scale on click */
    }
</style>

</head>
<body>
<center>
    <h1> Subscribe App </h1>
    <form method="post">
        <input type="email" name="email" placeholder="Enter your email" required />
        <br><br>
        <input type="submit" name="btn_subscribe" value="Subscribe" />
        <input type="submit" name="btn_unsubscribe" value="Unsubscribe" />
    </form>

    <%
        // Database credentials
        String dbURL = "jdbc:mysql://localhost:3306/email_subscription";
        String dbUser = "root";  // Replace with your MySQL username
        String dbPassword = "abc123";  // Replace with your MySQL password

        if(request.getParameter("btn_subscribe") != null) {
            String email = request.getParameter("email");
            boolean isNewEmail = false;

            // Database connection
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                // Load the JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");
                // Connect to the database
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                // Check if the email is already in the database
                String query = "SELECT * FROM subscribers WHERE email = ?";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();
                if(!rs.next()) {
                    // Insert the new email into the database
                    query = "INSERT INTO subscribers (email) VALUES (?)";
                    pstmt = conn.prepareStatement(query);
                    pstmt.setString(1, email);
                    pstmt.executeUpdate();
                    isNewEmail = true;
                }
            } catch(Exception e) {
                out.println("Database error: " + e.getMessage());
            } finally {
                try {
                    if(rs != null) rs.close();
                    if(pstmt != null) pstmt.close();
                    if(conn != null) conn.close();
                } catch(SQLException e) {
                    out.println("Error closing resources: " + e.getMessage());
                }
            }

            if(isNewEmail) {
                // Set mail properties
                Properties p = System.getProperties();
                p.put("mail.smtp.host", "smtp.gmail.com");
                p.put("mail.smtp.port", "587");
                p.put("mail.smtp.auth", "true");
                p.put("mail.smtp.starttls.enable", "true");

                // Authentication
                Session ms = Session.getInstance(p, new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        String un = "tester.anuj.mhatre.kc@gmail.com";
                        String pw = "wbkwoojioztcnasi";
                        return new PasswordAuthentication(un, pw);
                    }
                });

                try {
                    // Compose the message
                    MimeMessage msg = new MimeMessage(ms);
                    String subject = "Subscription Confirmation";
                    msg.setSubject(subject);
                    String txt = "You have successfully subscribed with the email: " + email;
                    msg.setText(txt);
                    msg.setFrom(new InternetAddress("tester.anuj.mhatre.kc@gmail.com"));
                    msg.addRecipient(Message.RecipientType.TO, new InternetAddress(email));

                    // Send the message
                    Transport.send(msg);
                    out.println("Subscription successful! A confirmation email has been sent to " + email);
                } catch(Exception e) {
                    out.println("Issue sending email: " + e.getMessage());
                }
            } else {
                out.println("This email is already subscribed.");
            }
        } else if(request.getParameter("btn_unsubscribe") != null) {
            String email = request.getParameter("email");
            boolean emailExists = false;

            // Database connection
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                // Load the JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");
                // Connect to the database
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                // Check if the email is in the database
                String query = "SELECT * FROM subscribers WHERE email = ?";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    // Delete the email from the database
                    query = "DELETE FROM subscribers WHERE email = ?";
                    pstmt = conn.prepareStatement(query);
                    pstmt.setString(1, email);
                    pstmt.executeUpdate();
                    emailExists = true;
                }
            } catch(Exception e) {
                out.println("Database error: " + e.getMessage());
            } finally {
                try {
                    if(rs != null) rs.close();
                    if(pstmt != null) pstmt.close();
                    if(conn != null) conn.close();
                } catch(SQLException e) {
                    out.println("Error closing resources: " + e.getMessage());
                }
            }

            if(emailExists) {
                // Set mail properties
                Properties p = System.getProperties();
                p.put("mail.smtp.host", "smtp.gmail.com");
                p.put("mail.smtp.port", "587");
                p.put("mail.smtp.auth", "true");
                p.put("mail.smtp.starttls.enable", "true");

                // Authentication
                Session ms = Session.getInstance(p, new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        String un = "tester.anuj.mhatre.kc@gmail.com";
                        String pw = "wbkwoojioztcnasi";
                        return new PasswordAuthentication(un, pw);
                    }
                });

                try {
                    // Compose the message
                    MimeMessage msg = new MimeMessage(ms);
                    String subject = "Unsubscription Confirmation";
                    msg.setSubject(subject);
                    String txt = "You have successfully unsubscribed with the email: " + email;
                    msg.setText(txt);
                    msg.setFrom(new InternetAddress("tester.anuj.mhatre.kc@gmail.com"));
                    msg.addRecipient(Message.RecipientType.TO, new InternetAddress(email));

                    // Send the message
                    Transport.send(msg);
                    out.println("Unsubscription successful! A confirmation email has been sent to " + email);
                } catch(Exception e) {
                    out.println("Issue sending email: " + e.getMessage());
                }
            } else {
                out.println("This email is not subscribed.");
            }
        }
    %>
</center>
</body>
</html>
