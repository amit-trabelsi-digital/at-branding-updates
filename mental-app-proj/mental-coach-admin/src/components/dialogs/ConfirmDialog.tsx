import React from "react";
import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import Button from "@mui/material/Button";

type ConfirmDialogProps = {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  content: React.ReactNode;
};

const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  open,
  onClose,
  onConfirm,
  title,
  content,
}) => {
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle align="center" margin={2}>
        {title}
      </DialogTitle>
      <DialogContent>{content}</DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="primary">
          ביטול
        </Button>
        <Button onClick={onConfirm} color="secondary">
          אישור
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ConfirmDialog;
