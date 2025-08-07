/* eslint-disable @typescript-eslint/no-explicit-any */
import { yupResolver } from "@hookform/resolvers/yup";
import CloseIcon from "@mui/icons-material/Close";
import { LoadingButton } from "@mui/lab";
import {
  AppBar,
  Button,
  IconButton,
  MenuItem,
  Stack,
  Toolbar,
  Typography,
} from "@mui/material";
import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import * as yup from "yup";
import {
  yupStringSchema,
  yupStringSchema_optional,
} from "../../utils/validators";

import EditIcon from "@mui/icons-material/Edit";
import { enqueueSnackbar } from "notistack";
import { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, PushMessages } from "../../utils/types";
import AppSelectWithController from "../general/AppSelectWithController";
import PersonIcon from "@mui/icons-material/Person";
import AppFormTextField from "../general/AppFormTextField";
import AppTextArea from "../general/AppTextArea";
import AppDialog from "../general/AppDialog";

const APEARIANCE_LIST = [
  { label: "במסך הרשמה", value: "registeration" },
  { label: "במסך דשבורד לפני משחק", value: "dashboard" },
  { label: "פוש בדחיפה 12 שעות לפני שעת תחילת המשחק", value: "1-before" },
  { label: "אם המשתמש סימן חרדה במשחק", value: "anxiety" }, // חרדה
];

type Props = BaseDialogProps & { selectedItem: PushMessages | null };

function PushMessagesDialog({ open, onClose, selectedItem }: Props) {
  const [loading, setLoading] = useState(false);

  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;
  console.log(selectedItem);

  const objectSchema = {
    title: yupStringSchema,
    message: yupStringSchema,
    dataLink: yupStringSchema_optional,
    readMoreLink: yupStringSchema_optional,
    notes: yupStringSchema_optional,
    appearedIn: yupStringSchema,
  };
  const schema = yup.object().shape(objectSchema);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    reset,
    control,
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: schema.getDefault(),
  });

  useEffect(() => {
    if (selectedItem) {
      console.log(selectedItem);
      for (const key in objectSchema) {
        const _key = key as keyof typeof objectSchema;
        const value = selectedItem[_key] ?? null;

        setValue(_key, value);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedItem]);

  const onSubmit = handleSubmit(async (data) => {
    console.log(data);
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode
          ? "/api/pushMessages"
          : `/api/pushMessages/${selectedItem!._id}`,
        {
          method: isCreationMode ? "POST" : "PUT",
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) {
        const error = await res.json();
        throw new Error(error.message);
      }
      enqueueSnackbar(isEditMode ? "השינויים נשמרו" : `מקרה חדש נוצר`);
      onCloseHandler();
      mutate("/api/pushMessages");
    } catch (error: any) {
      enqueueSnackbar(error?.message || `שגיאה`, {
        variant: "error",
      });
    } finally {
      setLoading(false);
    }
  });

  const onCloseHandler = () => {
    onClose();
    reset();
    setIsEditMode(false);
  };

  return (
    <AppDialog open={open} onClose={onCloseHandler}>
      <AppBar sx={{ position: "relative" }}>
        <Toolbar>
          <PersonIcon />
          <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
            {isEditMode
              ? "ערוך מקרה"
              : isViewMode
              ? `פרטים של ${selectedItem.title}`
              : "צור מקרה"}
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
      <form onSubmit={onSubmit}>
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

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="title"
            label={"שם המסר"}
          />

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="message"
            label={"תכולות המסר"}
          />

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="dataLink"
            label={"קישור לוידיו / אודיו"}
          />

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="readMoreLink"
            label={"קישור להרחבה"}
          />

          <AppSelectWithController
            isViewMode={isViewMode}
            errors={errors}
            required
            label="שלב שבו יופיע"
            fieldKey="appearedIn"
            control={control}
          >
            {APEARIANCE_LIST.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>

          <AppTextArea
            register={register}
            fieldKey="notes"
            isViewMode={isViewMode}
            errors={errors}
          />
          {!isViewMode && (
            <LoadingButton loading={loading} type="submit" variant="contained">
              {isEditMode ? "שמור" : "צור"}
            </LoadingButton>
          )}
        </Stack>
      </form>
    </AppDialog>
  );
}

export default PushMessagesDialog;
