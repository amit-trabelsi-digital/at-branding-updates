/* eslint-disable @typescript-eslint/no-explicit-any */
import { FormHelperText } from "@mui/material";
import { UseFormRegister, FieldErrors } from "react-hook-form";
import { FormLabel } from "@mui/material";

type Props = {
  label?: string;
  fieldKey: any;
  register: UseFormRegister<any>;
  errors: FieldErrors<any>;
  isViewMode?: boolean;
};

export default function AppTextArea({
  label,
  fieldKey,
  register,
  errors,
  isViewMode,
  ...props
}: Props) {
  return (
    <>
      {label && <FormLabel>{label}</FormLabel>}
      <textarea
        {...props}
        {...register(fieldKey)}
        placeholder="הערות"
        style={{
          borderColor: isViewMode ? "#f0f0f0" : "#c4c4c4",
          fontFamily: "Assistant ",
          height: "90px",
          borderRadius: "4px",
          padding: 10,
          fontSize: 18,
        }}
        readOnly={isViewMode}
      />
      <FormHelperText>{errors[fieldKey]?.message as string}</FormHelperText>
    </>
  );
}
