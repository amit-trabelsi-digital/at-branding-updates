/* eslint-disable @typescript-eslint/no-explicit-any */
import { yupResolver } from "@hookform/resolvers/yup";
import CloseIcon from "@mui/icons-material/Close";
import { LoadingButton } from "@mui/lab";
import {
  AppBar,
  Button,
  IconButton,
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
import { BaseDialogProps, Team } from "../../utils/types";
import AppFormTextField from "../general/AppFormTextField";
import AppSubtitle from "../general/AppSubtitle";
import AppDialog from "../general/AppDialog";
import AppColorPicker from "../general/AppColorPicker";

type Props = BaseDialogProps & { selectedItem: Team | null };

function TeamDialog({ open, onClose, selectedItem }: Props) {
  const [loading, setLoading] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;
  console.log(selectedItem);

  const objectSchema = {
    name: yupStringSchema,
    city: yupStringSchema,
    hex1: yupStringSchema_optional,
    hex2: yupStringSchema_optional,
    hex3: yupStringSchema_optional,
  };
  const schema = yup.object().shape(objectSchema);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    reset,
    getValues,
    // control,
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
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? `/api/teams` : `/api/teams/${selectedItem!._id}`,
        {
          method: isCreationMode ? "POST" : "PUT",
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) {
        const error = await res.json();
        console.log(error);
        throw new Error(error.message);
      }
      enqueueSnackbar(isEditMode ? "השינויים נשמרו" : `ליגה חדש נוצר`);
      onCloseHandler();
      mutate("/api/teams");
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
          <IconButton
            edge="start"
            color="inherit"
            onClick={onCloseHandler}
            aria-label="close"
          >
            <CloseIcon />
          </IconButton>
          {(isEditMode || isCreationMode) && (
            <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
              {isEditMode ? "ערוך" : "צור"} ליגה{" "}
            </Typography>
          )}
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
          <AppSubtitle>פרטי הקבוצה</AppSubtitle>

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="name"
            label={"שם הקבוצה"}
          />
          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="city"
            label={"שם העיר"}
          />
          <AppColorPicker
            label={"צבע ראשי"}
            setValue={setValue}
            getValues={getValues}
            fieldName={"hex1"}
            disabled={isViewMode}
          />
          <AppColorPicker
            label={"צבע משני"}
            setValue={setValue}
            getValues={getValues}
            fieldName={"hex2"}
            disabled={isViewMode}
          />
          <AppColorPicker
            label={"צבע שלישי"}
            setValue={setValue}
            getValues={getValues}
            fieldName={"hex3"}
            disabled={isViewMode}
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

export default TeamDialog;
