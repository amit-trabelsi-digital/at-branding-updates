import { Section, Row, Column, Img, Link } from "@react-email/components";
import React from "react";

export const EmailHeader: React.FC = () => (
  <Section style={{ paddingLeft: "32px", paddingRight: "6px", paddingTop: "40px", paddingBottom: "40px" }}>
    <Row>
      <Column style={{ width: "80%", borderRadius: "8px", paddingRight: "6px" }}>
        <Img
          alt="mental coach logo"
          height="42"
          src="https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/public%2Flogo.png?alt=media&token=3e30ab23-a6a8-4a02-ad8b-8c07dbec8b81"
        />
      </Column>
      <Column align="left">
        <Row align="left">
          <Column>
            <Link href="#">
              <Img style={{ marginLeft: "4px", marginRight: "4px" }} height="36" src="https://react.email/static/x-logo.png" width="36" />
            </Link>
          </Column>
          <Column>
            <Link href="#">
              <Img
                style={{ marginLeft: "4px", marginRight: "4px" }}
                height="36"
                src="https://react.email/static/instagram-logo.png"
                width="36"
              />
            </Link>
          </Column>
          <Column>
            <Link href="#">
              <Img
                style={{ marginLeft: "4px", marginRight: "4px" }}
                height="36"
                src="https://react.email/static/facebook-logo.png"
                width="36"
              />
            </Link>
          </Column>
        </Row>
      </Column>
    </Row>
  </Section>
);

// https://mntl-app.eitanazaria.co.il
