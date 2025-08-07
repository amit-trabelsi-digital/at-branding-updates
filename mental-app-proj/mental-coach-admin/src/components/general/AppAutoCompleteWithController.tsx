/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  FormControl,
  TextField,
  Autocomplete,
  // darken,
  // lighten,
  // styled,
} from "@mui/material";
import { Control, Controller, FieldErrors } from "react-hook-form";

type Props = {
  control: Control<any>;
  fieldKey: string;
  label: string;
  options: { value: string | number; label: string }[];
  required?: boolean;
  errors: FieldErrors<any>;
  isViewMode: boolean;
};

// const GroupHeader = styled("div")(({ theme }) => ({
//   position: "sticky",
//   top: "-8px",
//   padding: "4px 10px",
//   color: theme.palette.primary.main,
//   backgroundColor: lighten(theme.palette.primary.light, 0.85),
//   ...theme.applyStyles("dark", {
//     backgroundColor: darken(theme.palette.primary.main, 0.8),
//   }),
// }));

function AppAutoCompleteMultiSelectWithController({
  control,
  fieldKey,
  label,
  errors,
  options,
  isViewMode,
  required = false,
}: Props) {
  return (
    <FormControl size="small" required={required} fullWidth>
      <Controller
        name={fieldKey}
        control={control}
        render={({ field }) => {
          // Handle both string values and option objects
          const getValue = () => {
            if (typeof field.value === 'string') {
              // If it's a string, try to find a matching option
              const matchingOption = options.find(opt => opt.value === field.value);
              return matchingOption || field.value;
            }
            return field.value;
          };

          return (
            <Autocomplete
              {...field}
              value={getValue()}
              freeSolo
              autoSelect
              readOnly={isViewMode}
              options={options}
              getOptionLabel={(option) => {
                // Handle both option objects and string values
                if (typeof option === 'string') {
                  return option;
                }
                return option.label || '';
              }}
              isOptionEqualToValue={(option, value) => {
                if (typeof value === 'string') {
                  return option.value === value || option.label === value;
                }
                return option.value === value?.value;
              }}
              onChange={(_, data) => {
                // If data is null, clear the field
                if (data === null) {
                  field.onChange('');
                } 
                // If data is a string (free text), save the string
                else if (typeof data === 'string') {
                  field.onChange(data);
                } 
                // If data is an option object, save just the value
                else {
                  field.onChange(data.value);
                }
              }}
              onInputChange={(_, newValue, reason) => {
                // Handle free text input
                if (reason === 'input') {
                  const matchingOption = options.find(
                    opt => opt.label.toLowerCase() === newValue.toLowerCase()
                  );
                  if (!matchingOption && newValue) {
                    // If no matching option, save the free text
                    field.onChange(newValue);
                  }
                }
              }}
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
          );
        }}
      />
    </FormControl>
  );
}

export default AppAutoCompleteMultiSelectWithController;
