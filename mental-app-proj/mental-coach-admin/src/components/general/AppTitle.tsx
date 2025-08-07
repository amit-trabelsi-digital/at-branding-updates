import { Typography } from "@mui/material";

type Props = {
  title: string;
};

export default function AppTitle({ title }: Props) {
  return (
    <Typography
      align="center"
      color="secondary"
      fontSize={60}
      fontWeight={700}
      variant="h3"
    >
      {title}
    </Typography>
  );
}
