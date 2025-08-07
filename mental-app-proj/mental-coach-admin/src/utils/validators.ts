import * as yup from "yup";

export const yupStringSchema = yup.string().trim().required("חובה").default("");
export const yupNumberSchema = yup
  .number()
  .required("חובה")
  .nullable()
  .default(null);
export const yupStringSchema_optional = yup.string().trim().nullable();
// .default(undefined);
export const yupEmailSchema = yup
  .string()
  .trim()
  .email("מייל לא תקין")
  .required("חובה")
  .default("");

export const yupPhoneSchema = yup
  .string()
  .matches(/^05\d-?\d{7}$/, "נא להכניס מספר תקין")
  .required("שדה חובה");

export const yupPhoneSchema_optional = yup
  .string()
  .transform((value) => (value === "" ? null : value))
  .nullable()
  .optional()
  .test("phone-format", "נא להכניס מספר תקין", function(value) {
    if (!value || value === "") return true; // Allow empty values
    return /^05\d-?\d{7}$/.test(value);
  });

export const yupNumberSchema_optional = yup.number().nullable().optional().default(null);
