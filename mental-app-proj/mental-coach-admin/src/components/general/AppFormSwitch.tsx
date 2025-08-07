/* eslint-disable @typescript-eslint/no-explicit-any */
import { Switch, FormControlLabel } from "@mui/material";
import { FieldValues, Path, UseFormRegister } from "react-hook-form";

interface AppFormSwitchProps<T extends FieldValues> {
  label: string;
  fieldKey: Path<T>;
  isViewMode?: boolean;
  register: UseFormRegister<any>;
}

const AppFormSwitch = <T extends FieldValues>({
  label,
  fieldKey,
  isViewMode = false,
  register,
}: AppFormSwitchProps<T>) => {
  return (
    <FormControlLabel
      control={
        <Switch {...register(fieldKey)} color="primary" disabled={isViewMode} />
      }
      label={label}
      labelPlacement="end"
    />
  );
};

export default AppFormSwitch;
