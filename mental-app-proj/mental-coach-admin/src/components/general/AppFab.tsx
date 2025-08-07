/* eslint-disable @typescript-eslint/no-explicit-any */
import { Fab } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import { ReactNode } from "react";

type Props = {
  DialogTrigger: (data?: any) => void;
  icon?: ReactNode;
  text: string;
};

export default function AppFab({
  DialogTrigger,
  text,
  icon = <AddIcon sx={{ mr: 1 }} />,
}: Props) {
  return (
    <Fab
      variant="extended"
      color="primary"
      sx={{
        position: "fixed",
        top: 80,
        right: 20, // מיקום בצד ימין
        zIndex: 1200,
        "&:hover": {
          backgroundColor: "secondary.main", // Changes color on hover
        },
      }}
      onClick={() => DialogTrigger()}
    >
      {icon}
      {text}
    </Fab>
  );
}
