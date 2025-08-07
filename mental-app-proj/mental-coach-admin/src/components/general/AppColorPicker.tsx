/* eslint-disable @typescript-eslint/no-explicit-any */
import { useRef, useState } from "react";
import AppButton from "./AppButton";
import AppColorBall from "./AppColorBall";
import { UseFormGetValues, UseFormSetValue } from "react-hook-form";

type Props = {
  label: string;
  fieldName: any;
  setValue: UseFormSetValue<any>;
  getValues: UseFormGetValues<any>;
  disabled: boolean;
};

const AppColorPicker = ({
  label,
  setValue,
  fieldName,
  getValues,
  disabled,
}: Props) => {
  const colorValue = getValues(fieldName) || "#ffffff";
  const [color, setColor] = useState(colorValue);
  const inputRef = useRef<HTMLInputElement | null>(null);
  return (
    <div style={{ display: "flex", gap: 10 }}>
      <AppButton
        disabled={disabled}
        _label={`בחירת גוון ל${label}`}
        onClick={() => {
          if (inputRef.current) {
            inputRef.current.click();
          }
        }}
      />

      <input
        ref={(e) => {
          inputRef.current = e;
        }}
        style={{
          display: "none",
        }}
        type="color"
        value={color}
        onChange={(e) => {
          setValue(fieldName, e.target.value);
          setColor(e.target.value);
        }}
      />
      <AppColorBall hexColor={color} />
    </div>
  );
};

export default AppColorPicker;
