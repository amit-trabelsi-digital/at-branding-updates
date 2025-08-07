/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState } from "react";

type UseDialogArgs = {
  setItem?: (data: any | null) => void;
  initialOpen: boolean;
};

function useDialog(options: UseDialogArgs = { initialOpen: false }) {
  const [open, setOpen] = useState(options.initialOpen);
  const closeDialog = () => {
    setOpen(false);
    setTimeout(() => {
      if (options.setItem) {
        options.setItem(null);
      }
    }, 400);
  };
  const openDialog = (data?: any) => {
    setOpen(true);
    if (options.setItem && data) {
      options.setItem(data);
    }
  };
  return { open, closeDialog, openDialog };
}

export default useDialog;
