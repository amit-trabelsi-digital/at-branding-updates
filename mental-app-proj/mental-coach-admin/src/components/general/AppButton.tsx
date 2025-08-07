import { Button, ButtonProps, Typography } from "@mui/material";

type Props = ButtonProps & {
  _label: string;
  bgcolor?: string;
};

function AppButton({ _label, bgcolor = "white", ...props }: Props) {
  return (
    <Button
      sx={{
        px: 3,
        py: 1,
        borderRadius: 8,
        width: { xs: "auto", md: 200 },
        color: bgcolor,
      }}
      variant="contained"
      {...props}
    >
      <Typography textTransform={"none"} fontFamily={"Arial Rounded MT Bold"}>
        {_label}
      </Typography>
    </Button>
  );
}

export default AppButton;
