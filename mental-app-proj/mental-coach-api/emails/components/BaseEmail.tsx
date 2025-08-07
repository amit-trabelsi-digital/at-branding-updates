import React from "react";
import { Layout } from "../components/Layout";
import { Body, Html, Img, Link, Preview, Row, Section, Text } from "@react-email/components";
import { CSSProperties } from "react";

const main: CSSProperties = {
  backgroundColor: "#ffffff",
  margin: "0 auto",
  direction: "rtl",
  fontFamily:
    "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
};
export const BaseEmail: React.FunctionComponent<{ children: React.ReactNode }> = ({ children }) => (
  <Html>
    <Body style={main}>
      <Layout>{children}</Layout>
    </Body>
  </Html>
);
