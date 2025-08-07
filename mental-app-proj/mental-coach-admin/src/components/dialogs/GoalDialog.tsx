/* eslint-disable @typescript-eslint/no-explicit-any */
import { yupResolver } from "@hookform/resolvers/yup";
import CloseIcon from "@mui/icons-material/Close";
import { LoadingButton } from "@mui/lab";
import {
  AppBar,
  Button,
  FormControlLabel,
  IconButton,
  Stack,
  Switch,
  Toolbar,
  Typography,
} from "@mui/material";
import { useEffect, useState } from "react";
import { Controller, useForm } from "react-hook-form";
import * as yup from "yup";
import { yupStringSchema } from "../../utils/validators";
import EditIcon from "@mui/icons-material/Edit";
import { enqueueSnackbar } from "notistack";
import { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, Goal } from "../../utils/types";
import { POSITIONS } from "../../data/lists";
import PersonIcon from "@mui/icons-material/Person";
import AppSubtitle from "../general/AppSubtitle";
import AppAutoCompleteMultiSelectWithController from "../general/AppAutoCompleteMultiSelectWithController";
import AppFormTextField from "../general/AppFormTextField";
import AppDialog from "../general/AppDialog";

type Props = BaseDialogProps & { selectedItem: Goal | null };

function GoalDialog({ open, onClose, selectedItem }: Props) {
  const [loading, setLoading] = useState(false);

  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;
  console.log(selectedItem);

  const objectSchema = {
    goalName: yupStringSchema,
    positions: yup.array(),
    measurable: yup.boolean().default(true),
    trainingCompatible: yup.boolean().default(true),
  };
  const schema = yup.object().shape(objectSchema);

  const [missingPositions, setMissingPositions] = useState("");

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

        console.log(_key, value);
        setValue(_key, value);
      }
      const filtered = POSITIONS.filter(
        (position) =>
          !(selectedItem.positions || []).some(
            (selectedPos) => selectedPos.value === position.value
          )
      )
        .map((pos) => pos.label)
        .join(", ");

      setMissingPositions(filtered);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedItem]);

  const onSubmit = handleSubmit(async (data) => {
    console.log(data);
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? "/api/goals" : `/api/goals/${selectedItem!._id}`,
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
      mutate("/api/goals");
      reset();
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
              ? `פרטים של ${selectedItem.goalName}`
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
          <AppSubtitle>פרטי מקרה</AppSubtitle>
          <AppFormTextField
            errors={errors}
            isViewMode={isViewMode}
            register={register}
            fieldKey="goalName"
            label={"מטרה"}
          />
          <AppAutoCompleteMultiSelectWithController
            isViewMode={isViewMode}
            label="עמדות"
            control={control}
            fieldKey="positions"
            options={POSITIONS}
            errors={errors}
          />
          {missingPositions && (
            <Typography variant="body2" color="info">
              {"חסרות עמדות : "}
              {missingPositions}
            </Typography>
          )}

          <FormControlLabel
            control={
              <Controller
                control={control}
                name="measurable"
                render={({ field }) => (
                  <Switch
                    {...field}
                    checked={field.value}
                    color="primary"
                    disabled={isViewMode}
                  />
                )}
              />
            }
            label={"מדיד"}
            labelPlacement="end"
          />

          <FormControlLabel
            control={
              <Controller
                control={control}
                name="trainingCompatible"
                render={({ field }) => (
                  <Switch
                    {...field}
                    checked={field.value}
                    color="primary"
                    disabled={isViewMode}
                  />
                )}
              />
            }
            label={"תואם אימון"}
            labelPlacement="end"
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

export default GoalDialog;
