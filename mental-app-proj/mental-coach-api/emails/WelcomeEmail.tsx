import * as React from "react";
import { Button } from "@react-email/components";
import { BaseEmail } from "./components/BaseEmail";
import { buttonStyle } from "./styles/emailStyles";
interface WelcomeEmailProps {
  firstName: string;
  url: string;
  subject: string;
}

const WelcomeEmail: React.FC<WelcomeEmailProps> = ({ firstName, url, subject }) => {
  console.log("WelcomeEmail", { firstName, url, subject });

  return (
    <BaseEmail>
      <div>
        <h1>{subject}</h1>
        <p>שלום {firstName},</p>
        <p>ברוכים הבאים למנטאלי בכיס!</p>
      </div>

      <Button style={buttonStyle} href="https://menta-coach-assetlink.netlify.app/dashboard/2">
        לאפליקציה
      </Button>
    </BaseEmail>
  );
};

export default WelcomeEmail;
