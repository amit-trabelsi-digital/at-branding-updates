import React from "react";
import { EmailHeader } from "./EmailHeader";
import { EmailFooter } from "./EmailFooter";

import { Body, Column, Container, Head, Heading, Html, Img, Link, Preview, Row, Section, Text } from "@react-email/components";

export const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div style={{ fontFamily: "Arial, sans-serif", padding: "20px", backgroundColor: "#f9f9f9", direction: "rtl" }}>
    <EmailHeader />
    <Head />
    <div style={{ margin: "20px 0" }}>{children}</div>
    <EmailFooter />
  </div>
);
