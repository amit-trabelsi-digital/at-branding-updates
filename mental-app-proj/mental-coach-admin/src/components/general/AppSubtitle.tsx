import { TypographyProps, Typography } from "@mui/material";
import React from "react";

export default function AppSubtitle({
  children,
  ...props
}: TypographyProps & { children: React.ReactNode }) {
  return (
    <Typography
      display={"block"}
      whiteSpace={"nowrap"}
      mb={0.5}
      fontWeight={600}
      {...props}
    >
      {children}
    </Typography>
  );
}
