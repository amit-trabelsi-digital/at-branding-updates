import { ReactNode } from "react";
import { Transition } from "../general/GeneralRenderComp";
import { Dialog } from "@mui/material";

type Props = {
  onClose: () => void;
  open: boolean;
  children: ReactNode;
};

export default function AppDialog({ onClose, open, children }: Props) {
  return (
    <Dialog
      sx={{ maxWidth: "50dvw" }}
      open={open}
      onClose={onClose}
      fullScreen
      TransitionComponent={Transition}
    >
      {children}
    </Dialog>
  );
}
