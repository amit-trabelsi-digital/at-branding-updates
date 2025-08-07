import {
  Stack,
  Button,
  Toolbar,
  Typography,
  IconButton,
  AppBar,
  FormLabel,
  MenuItem,
  FormControlLabel,
  Switch,
  Divider,
  FormGroup,
  Checkbox,
  Box,
} from "@mui/material";
import AppDialog from "../general/AppDialog";
import PersonIcon from "@mui/icons-material/Person";
import CloseIcon from "@mui/icons-material/Close";
import EditIcon from "@mui/icons-material/Edit";
import AppFormTextField from "../general/AppFormTextField";
import AppSubtitle from "../general/AppSubtitle";
import { BaseDialogProps, Team, User } from "../../utils/types";
import { appFetch } from "../../services/fetch";
import { enqueueSnackbar } from "notistack";
import { useForm, Controller } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import { POSITIONS, SUBSCRIPTION_TYPE_LIST, ISRAELY_LEAGUES } from "../../data/lists";
import { useEffect, useState } from "react";
import AppSelectWithController from "../general/AppSelectWithController";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DesktopDatePicker } from "@mui/x-date-pickers/DesktopDatePicker";
import dayjs from "dayjs";
import useSWR from "swr";
import {
  yupEmailSchema,
  yupNumberSchema_optional,
  yupPhoneSchema_optional,
  yupStringSchema,
  yupStringSchema_optional,
} from "../../utils/validators";

import { useSWRConfig } from "swr";
import AppAutoCompleteWithController from "../general/AppAutoCompleteWithController";

// Function
const fixedTeamArrayFunction = (
  data: Team[] | undefined
): { value: string | number; label: string }[] => {
  if (!data) return [];
  return data.map((i: Team) => ({ value: i._id || '', label: i.name || '' }));
};

type Props = BaseDialogProps & { selectedItem: User | null };

function UserDialog({ open, onClose, selectedItem }: Props) {
  const [loading, setLoading] = useState(false);


  const { data: teams } = useSWR<Team[]>("/api/teams");
  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;

  const objectSchema = {
    firstName: yupStringSchema,
    lastName: yupStringSchema,
    email: yupEmailSchema,
    phone: yupPhoneSchema_optional,
    password: yup.string()
      .trim()
      .min(6, "לפחות 6 תווים")
      .optional()
      .nullable(),
    subscriptionType: yupStringSchema_optional.default(
      SUBSCRIPTION_TYPE_LIST[0].value
    ),
    nickName: yupStringSchema_optional,
    age: yupNumberSchema_optional,
    position: yupStringSchema_optional,
    strongLeg: yupStringSchema_optional,
    league: yupStringSchema_optional,
    team: yupStringSchema_optional,
    isAdmin: yup.boolean().default(false),
    coachWhatsappNumber: yupPhoneSchema_optional,
    subscriptionExpiresAt: yup.date().nullable().optional(),
    transactionId: yupStringSchema_optional,
    firebasePhoneNumber: yup.string()
      .matches(/^\+[1-9]\d{1,14}$/, "מספר הטלפון חייב להיות בפורמט בינלאומי (E.164)")
      .optional()
      .nullable(),
    allowedAuthMethods: yup.object().shape({
      email: yup.boolean().default(false),
      sms: yup.boolean().default(true),
      google: yup.boolean().default(true),
    }).default({
      email: false,
      sms: true,
      google: true,
    }),
  };
  const schema = yup.object().shape(objectSchema);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    reset,
    control,
    watch,
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: schema.getDefault(),
  });

  // Log validation errors
  useEffect(() => {
    if (Object.keys(errors).length > 0) {
      console.log("Validation errors:", errors);
    }
  }, [errors]);

  // Helper function to convert Israeli phone to international format
  const convertToInternationalFormat = (phone: string): string => {
    if (!phone) return "";
    
    // Remove all non-digit characters
    let cleanPhone = phone.replace(/\D/g, "");
    
    // Handle Israeli numbers
    if (cleanPhone.startsWith("05")) {
      cleanPhone = "972" + cleanPhone.substring(1);
    } else if (cleanPhone.startsWith("5") && cleanPhone.length === 9) {
      cleanPhone = "972" + cleanPhone;
    }
    
    // Ensure it starts with +
    if (!cleanPhone.startsWith("+")) {
      cleanPhone = "+" + cleanPhone;
    }
    
    return cleanPhone;
  };

  useEffect(() => {
    if (selectedItem && open) {
      const phoneField = selectedItem.phone || "";
      const firebasePhoneNumber = selectedItem.firebasePhoneNumber || 
                                 (phoneField ? convertToInternationalFormat(phoneField) : "");
      
      reset({
        ...selectedItem,
        firebasePhoneNumber,
        phone: phoneField,
        subscriptionExpiresAt: selectedItem.subscriptionExpiresAt
          ? new Date(selectedItem.subscriptionExpiresAt)
          : null,
        allowedAuthMethods: selectedItem.allowedAuthMethods || {
          email: false,
          sms: true,
          google: true,
        },
      });
    } else if (!selectedItem && open) {
      reset({
        isAdmin: false,
        phone: "",
        firebasePhoneNumber: "",
        subscriptionType: SUBSCRIPTION_TYPE_LIST[0].value,
        allowedAuthMethods: {
          email: false,
          sms: true,
          google: true,
        },
      });
    }
  }, [selectedItem, open, reset]);

  // Watch phone field changes and auto-update firebase phone
  const phoneValue = watch("phone");
  useEffect(() => {
    if (phoneValue) {
      const internationalPhone = convertToInternationalFormat(phoneValue);
      if (internationalPhone) {
        setValue("firebasePhoneNumber", internationalPhone);
      }
    }
  }, [phoneValue, setValue]);

  // Watch isAdmin field and update auth methods for admin users
  const isAdminValue = watch("isAdmin");
  useEffect(() => {
    if (isAdminValue) {
      // אם המשתמש הוא מנהל, גם SMS וגם Google צריכים להיות מסומנים
      setValue("allowedAuthMethods.sms", true);
      setValue("allowedAuthMethods.google", true);
    }
  }, [isAdminValue, setValue]);

  const { mutate } = useSWRConfig();

  const onSubmit = async (data: yup.InferType<typeof schema>) => {
    setLoading(true);
    try {
      // Ensure we have a valid firebasePhoneNumber if phone is provided
      if (data.phone && !data.firebasePhoneNumber) {
        data.firebasePhoneNumber = convertToInternationalFormat(data.phone);
      }

      // Convert isAdmin boolean to role number for backwards compatibility
      const { isAdmin, ...restData } = data;
      const dataToSend = {
        ...restData,
        role: isAdmin ? 0 : 3,
      };

      const url = isCreationMode
        ? "/api/users/"
        : `/api/users/${selectedItem?._id}`;
      const method = isCreationMode ? "POST" : "PUT";

      const response = await appFetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(dataToSend),
      });

      await response.json();
      mutate("/api/users");
      enqueueSnackbar("שינויים נשמרו", { variant: "success" });
      onCloseHandler();
    } catch {
      enqueueSnackbar("תקלה בשמירה", { variant: "error" });
    }
    setLoading(false);
  };

  const onCloseHandler = () => {
    setIsEditMode(false);
    onClose();
  };

  const teamsOptions = fixedTeamArrayFunction(teams) || [
    { value: "", label: "" },
  ];

  const leaguesOptions = ISRAELY_LEAGUES?.map((league) => ({ 
    value: league.value, 
    label: league.label 
  })) || [];
  return (
    <AppDialog open={open} onClose={onCloseHandler}>
      <AppBar sx={{ position: "relative" }}>
        <Toolbar sx={{ borderRadius: 0 }}>
          <PersonIcon />
          <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
            {isEditMode
              ? "ערוך משתמש"
              : isViewMode
              ? `פרטים של ${selectedItem?.firstName}`
              : "צור משתמש"}
          </Typography>
          <IconButton
            edge="start"
            color="inherit"
            onClick={onCloseHandler}
            aria-label="close"
          >
            <CloseIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <form onSubmit={(e) => {
        console.log("Form submitted");
        e.preventDefault();
        handleSubmit(onSubmit)(e);
      }}>
        <Stack
          maxWidth={500}
          mx={"auto"}
          py={5}
          spacing={1.5}
          sx={{
            ".MuiOutlinedInput-notchedOutline": isViewMode
              ? {
                  border: "#f0f0f0 solid 1px !important",
                  "&:hover": { border: "#f0f0f0 solid 1px !important" },
                }
              : {},
            ".MuiFormLabel-root": isViewMode
              ? { color: "#666 !important" }
              : {},
          }}
        >
          {isViewMode && (
            <Button
              variant="outlined"
              sx={{ width: "fit-content", alignSelf: "flex-end" }}
              startIcon={<EditIcon />}
              onClick={() => setIsEditMode(true)}
              disabled={isEditMode}
            >
              עריכה
            </Button>
          )}
          
          {/* קבוצה 1: פרטים אישיים */}
          <AppSubtitle>פרטים אישיים</AppSubtitle>
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="firstName"
            label={"שם פרטי"}
          />
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="lastName"
            label={"שם משפחה"}
          />
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="nickName"
            label={"כינוי"}
          />
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="age"
            label={"גיל (אופציונלי)"}
          />
          
          {/* קבוצה 2: פרטי התקשרות */}
          <Divider sx={{ my: 2 }} />
          <AppSubtitle>פרטי התקשרות</AppSubtitle>
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="email"
            label={"מייל"}
            disabled={!isCreationMode}
          />
          {isCreationMode && (
            <AppFormTextField
              isViewMode={isViewMode}
              register={register}
              errors={errors}
              fieldKey="password"
              label={"סיסמה (אופציונלי)"}
              type="password"
              placeholder="השאר ריק אם משתמש רק ב-SMS/Google"
            />
          )}
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="phone"
            label={"טלפון"}
          />
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="coachWhatsappNumber"
            label="טלפון וואטסאפ של המאמן"
          />
          
          {/* קבוצה 3: פרטי כדורגל */}
          <Divider sx={{ my: 2 }} />
          <AppSubtitle>פרטי כדורגל</AppSubtitle>
          <AppSelectWithController
            errors={errors}
            isViewMode={isViewMode}
            label="עמדה"
            fieldKey="position"
            control={control}
          >
            {POSITIONS?.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          
          <AppSelectWithController
            errors={errors}
            isViewMode={isViewMode}
            label="רגל חזקה"
            fieldKey="strongLeg"
            control={control}
          >
            <MenuItem value="ימין">ימין</MenuItem>
            <MenuItem value="שמאל">שמאל</MenuItem>
            <MenuItem value="שתיהן">שתיהן</MenuItem>
          </AppSelectWithController>
          
          <AppAutoCompleteWithController
            control={control}
            errors={errors}
            fieldKey="team"
            isViewMode={isViewMode}
            label="קבוצה"
            options={teamsOptions}
          />
          
          <AppAutoCompleteWithController
            control={control}
            errors={errors}
            fieldKey="league"
            isViewMode={isViewMode}
            label="ליגה"
            options={leaguesOptions}
          />
          
          {/* קבוצה 4: הגדרות מנוי */}
          <Divider sx={{ my: 2 }} />
          <AppSubtitle>הגדרות מנוי</AppSubtitle>
          <AppSelectWithController
            errors={errors}
            isViewMode={isViewMode}
            label="סוג מנוי"
            fieldKey="subscriptionType"
            control={control}
          >
            {SUBSCRIPTION_TYPE_LIST?.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          
          <Controller
            name="subscriptionExpiresAt"
            control={control}
            render={({ field }) => (
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DesktopDatePicker
                  label="תוקף מנוי"
                  value={field.value ? dayjs(field.value) : null}
                  onChange={(date) => field.onChange(date?.toDate())}
                  disabled={isViewMode}
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      margin: "normal",
                      error: !!errors.subscriptionExpiresAt,
                      helperText: errors.subscriptionExpiresAt?.message,
                    },
                  }}
                />
              </LocalizationProvider>
            )}
          />
          
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="transactionId"
            label={"מזהה עסקה"}
          />
          
          {/* קבוצה 5: הגדרות התחברות */}
          <Divider sx={{ my: 2 }} />
          <AppSubtitle>הגדרות התחברות</AppSubtitle>
          
          <AppFormTextField
            isViewMode={isViewMode}
            register={register}
            errors={errors}
            fieldKey="firebasePhoneNumber"
            label={"מספר טלפון בפיירבייס (פורמט בינלאומי)"}
            placeholder="+972501234567"
            helperText="מספר הטלפון כפי שהוא מאוחסן בפיירבייס. חייב להתחיל ב-+ ואז קוד המדינה (לדוגמה: +972501234567)"
          />
          
          <Box>
            <FormLabel component="legend">שיטות התחברות מורשות</FormLabel>
            <FormGroup>
              <Controller
                name="allowedAuthMethods.email"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={
                      <Checkbox
                        {...field}
                        checked={field.value}
                        disabled={isViewMode}
                      />
                    }
                    label="התחברות עם אימייל וסיסמה"
                  />
                )}
              />
              <Controller
                name="allowedAuthMethods.sms"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={
                      <Checkbox
                        {...field}
                        checked={field.value}
                        disabled={isViewMode}
                      />
                    }
                    label="התחברות עם SMS"
                  />
                )}
              />
              <Controller
                name="allowedAuthMethods.google"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={
                      <Checkbox
                        {...field}
                        checked={field.value}
                        disabled={isViewMode}
                      />
                    }
                    label="התחברות עם Google"
                  />
                )}
              />

            </FormGroup>
          </Box>
          
          {/* קבוצה 6: הגדרות ניהול */}
          <Divider sx={{ my: 2 }} />
          <AppSubtitle>הגדרות ניהול</AppSubtitle>
          
          {isCreationMode ? (
            <FormControlLabel
              control={
                <Controller
                  control={control}
                  name="isAdmin"
                  render={({ field }) => (
                    <Switch
                      {...field}
                      checked={field.value}
                      color="primary"
                      disabled={isViewMode || isEditMode}
                    />
                  )}
                />
              }
              label={"האם המשתמש מנהל?"}
              labelPlacement="end"
            />
          ) : (
            <FormLabel>
              {`סוג משתמש: ${selectedItem?.role === 0 ? "מנהל" : "משתמש"} `}
            </FormLabel>
          )}
        </Stack>
        
        <Divider />
        <Stack px={2} py={3}>
          {!isViewMode && (
            <Button
              variant="contained"
              sx={{ alignSelf: "flex-end" }}
              type="submit"
              disabled={loading}
            >
              {isEditMode ? "עדכן" : "צור"}
            </Button>
          )}
        </Stack>
      </form>
    </AppDialog>
  );
}

export default UserDialog;