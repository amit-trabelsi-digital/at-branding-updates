/* eslint-disable @typescript-eslint/no-explicit-any */
import { TextFieldProps, TextField } from "@mui/material";
import { FieldErrors, UseFormRegister } from "react-hook-form";

type FormText = {
  label: string;
  fieldKey: any;
  register: UseFormRegister<any>;
  errors: FieldErrors<any>;
  isViewMode?: boolean;
} & TextFieldProps;

const AppFormTextField = ({
  label,
  fieldKey,
  register,
  errors,
  isViewMode,
  ...props
}: FormText) => {
  return (
    <TextField
      label={label}
      size="small"
      variant="outlined"
      {...register(fieldKey)}
      error={Boolean(errors[fieldKey]?.type)}
      helperText={errors[fieldKey]?.message as string}
      focused={isViewMode}
      slotProps={{
        input: {
          readOnly: isViewMode,
        },
      }}
      {...props}
    />
  );
};

export default AppFormTextField;
