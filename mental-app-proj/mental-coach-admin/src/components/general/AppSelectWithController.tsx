/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  FormControl,
  FormHelperText,
  InputLabel,
  Select,
  SelectProps,
} from "@mui/material";
import { Control, Controller, FieldErrors } from "react-hook-form";

type Props = SelectProps & {
  control: Control<any>;
  fieldKey: string;
  label: string;
  children: React.ReactNode;
  errors: FieldErrors<any>;
  isViewMode: boolean;
};

function AppSelectWithController({
  control,
  fieldKey,
  label,
  children,
  errors,
  required = false,
  isViewMode,
  ...selectProps
}: Props) {
  // const isError = false;
  const isError = Boolean(errors[fieldKey]?.type);

  return (
    <FormControl size="small" required={required} fullWidth error={isError}>
      <InputLabel>{label}</InputLabel>
      <Controller
        name={fieldKey}
        control={control}
        render={({ field }) => (
          <Select
            readOnly={isViewMode}
            required={required}
            label={label}
            fullWidth
            {...field}
            {...selectProps}
          >
            {children}
          </Select>
        )}
      />
      {isError && (
        <FormHelperText>{errors[fieldKey]?.message as string}</FormHelperText>
      )}
    </FormControl>
  );
}

export default AppSelectWithController;
