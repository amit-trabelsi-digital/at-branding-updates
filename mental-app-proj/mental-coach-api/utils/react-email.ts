import sgMail from "@sendgrid/mail";
import { render } from "@react-email/render";
import { convert } from "html-to-text";
import * as React from "react";
import Welcome from "../emails/WelcomeEmail";
import OpenMatch from "../emails/OpenMatch";
import { IUserMatch } from "../models/user-match-training-model";

sgMail.setApiKey(process.env.SENDGRID_API_KEY!);
export default class Email {
  private to: string;
  private firstName: string;
  private url?: string;
  private from: string;
  private match: IUserMatch | null | undefined;

  constructor(user: any, url?: string) {
    this.to = user.email;
    this.firstName = user.name;
    this.url = url;
    this.match = user.match;
    this.from = process.env.EMAIL_FROM ?? "amit@trabel.si";
  }

  private async send(template: React.FC<any>, subject: string, props: any): Promise<void> {
    const html = await render(React.createElement(template, props));

    const msg = {
      to: this.to,
      from: this.from,
      subject,
      html,
      text: convert(html),
    };

    await sgMail.send(msg);
  }

  async sendWelcome(): Promise<void> {
    await this.send(Welcome, `ברוכים הבאים למנטאלי בכיס!`, { firstName: this.firstName });
  }

  async sendOpenMatch(): Promise<void> {
    await this.send(OpenMatch, `המשחק נפתח להכנה`, { firstName: this.firstName, url: this.url, match: this.match });
  }
}
