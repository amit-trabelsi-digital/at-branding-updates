import { Backdrop, CircularProgress, Stack, Typography } from "@mui/material";

function AppLoadingBackdrop({ open = false, label = "טוען..." }) {
  return (
    <Backdrop sx={{ color: "white" }} open={open}>
      <Stack gap={1}>
        <CircularProgress color="inherit" />
        <Typography>{label}</Typography>
      </Stack>
    </Backdrop>
  );
}

export default AppLoadingBackdrop;
