import { CircularProgress, Stack, Typography } from "@mui/material";

function AppLoadingScreen() {
  return (
    <Stack
      sx={{
        justifyContent: "center",
        alignItems: "center",
        textAlign: "center",
        position: "fixed",
        gap: 1,
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        bgcolor: "#fff",
        zIndex: 1000,
      }}
    >
      <Stack sx={{ position: "relative" }} gap={1} alignItems="center">
        <CircularProgress size={70} />
        <Typography>טוען</Typography>
      </Stack>
    </Stack>
  );
}

export default AppLoadingScreen;
