type Props = {
  hexColor?: string;
  size?: "small" | "medium" | "large";
};

function AppColorBall({ hexColor = "#ffffff", size = "large" }: Props) {
  const _size = size === "small" ? 25 : size === "medium" ? 32 : 40;

  return (
    <div
      style={{
        width: _size,
        height: _size,
        borderRadius: "50%",
        backgroundColor: `${hexColor}`,
        boxShadow: "-1px 4px 23px -7px rgba(0,0,0,0.75)",
      }}
    />
  );
}

export default AppColorBall;
