import { Stack, Typography } from "@mui/material";
import Collapse from "@mui/material/Collapse/Collapse";
import React from "react";

const AppSectionContainer = ({
  children,
  title,
  isOpen = true,
}: {
  children: React.ReactNode;
  title: string;
  isOpen?: boolean;
}) => (
  <Collapse in={isOpen}>
    <Stack>
      <Typography>{title}</Typography>
      <Stack
        gap={1.5}
        sx={{
          padding: 2,
          border: "solid black 1px",
          borderRadius: "10px",
          boxShadow:
            "rgba(0, 0, 0, 0.12) 0px 1px 3px, rgba(0, 0, 0, 0.24) 0px 1px 2px",
        }}
      >
        {children}
      </Stack>
    </Stack>
  </Collapse>
);

export default AppSectionContainer;
