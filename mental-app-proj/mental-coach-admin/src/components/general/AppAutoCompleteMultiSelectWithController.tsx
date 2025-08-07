/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  FormControl,
  TextField,
  Autocomplete,
  Checkbox,
  FormControlLabel,
} from "@mui/material";
import { Control, Controller, FieldErrors } from "react-hook-form";

type Props = {
  control: Control<any>;
  fieldKey: string;
  label: string;
  options: { value: string | number | undefined; label: string | undefined }[];
  required?: boolean;
  errors: FieldErrors<any>;
  isViewMode: boolean;
};

function AppAutoCompleteMultiSelectWithController({
  control,
  fieldKey,
  label,
  errors,
  options,
  isViewMode,
  required = false,
}: Props) {
  const allOption = { value: "all", label: "בחר הכל" };

  const handleChange = (data: any[], field: any) => {
    if (data.some((item) => item.value === "all")) {
      const allOptions = options.filter((opt) => opt.value !== "all");
      field.onChange(allOptions);
    } else {
      field.onChange(data);
    }
  };

  return (
    <FormControl size="small" required={required} fullWidth>
      <Controller
        name={fieldKey}
        control={control}
        render={({ field }) => (
          <Autocomplete
            {...field}
            readOnly={isViewMode}
            multiple
            options={[allOption, ...options]}
            getOptionLabel={(option) => option.label || ""}
            isOptionEqualToValue={(option, value) =>
              option.value === value.value
            }
            onChange={(_, data) => handleChange(data, field)}
            renderOption={(props, option, { selected }) => (
              <li {...props}>
                <FormControlLabel
                  control={<Checkbox checked={selected} />}
                  label={option.label}
                />
              </li>
            )}
            renderInput={(params) => (
              <TextField
                {...params}
                label={label}
                required={required}
                variant="outlined"
                size="small"
                helperText={errors[fieldKey]?.message as string}
                error={Boolean(errors[fieldKey]?.type)}
              />
            )}
          />
        )}
      />
    </FormControl>
  );
}

export default AppAutoCompleteMultiSelectWithController;
