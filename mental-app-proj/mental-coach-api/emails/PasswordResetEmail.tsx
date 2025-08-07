import * as React from "react";

interface PasswordResetEmailProps {
  firstName: string;
  url: string;
  subject: string;
}

const PasswordResetEmail: React.FC<PasswordResetEmailProps> = ({ firstName, url, subject }) => {
  return (
    <div>
      <h1>{subject}</h1>
      <p>שלום {firstName},</p>
      <p>לאיפוס הסיסמה, לחץ על הקישור הבא (הקישור יהיה זמין רק ל-10 דקות):</p>
      <p>
        <a href={url}>{url}</a>
      </p>
    </div>
  );
};

export default PasswordResetEmail;
