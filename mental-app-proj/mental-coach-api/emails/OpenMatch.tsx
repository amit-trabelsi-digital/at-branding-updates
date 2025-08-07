import * as React from "react";
import { Button } from "@react-email/components";
import { BaseEmail } from "./components/BaseEmail";
import { buttonStyle } from "./styles/emailStyles";
import { IUserMatch } from "../models/user-match-training-model";
interface OpenMatchProps {
  firstName: string;
  url: string;
  subject: string;
  match: IUserMatch;
}

const OpenMatch: React.FC<OpenMatchProps> = ({ firstName, url, subject, match }) => {
  console.log("OpenMatch", { firstName, url, subject, match });

  return (
    <BaseEmail>
      <div>
        <h1>{subject}</h1>
        <p>שלום {firstName},</p>
        <p>{`המשחק ${match?.awayTeam.name} נגד ${match?.homeTeam.name} נפתח להכנה`}</p>
      </div>

      <Button style={buttonStyle} href={`https://menta-coach-assetlink.netlify.app/match-prepare/${match?._id.toString()}`}>
        להכנה
      </Button>
    </BaseEmail>
  );
};

export default OpenMatch;
