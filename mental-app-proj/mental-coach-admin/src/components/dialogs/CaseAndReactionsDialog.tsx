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
import useSWR, { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, CaseAndResponse } from "../../utils/types";
import AppSelectWithController from "../general/AppSelectWithController";
import { POSITIONS } from "../../data/lists";
import PersonIcon from "@mui/icons-material/Person";
import AppSubtitle from "../general/AppSubtitle";
import AppAutoCompleteMultiSelectWithController from "../general/AppAutoCompleteMultiSelectWithController";
import AppFormTextField from "../general/AppFormTextField";
import AppTextArea from "../general/AppTextArea";
import AppDialog from "../general/AppDialog";

type Props = BaseDialogProps & { selectedItem: CaseAndResponse | null };

function CaseAndResponseDialog({ open, onClose, selectedItem }: Props) {
  const [loading, setLoading] = useState(false);

  const { data: general } = useSWR("/api/general");

  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;

  const objectSchema = {
    case: yupStringSchema,
    response: yupStringSchema,
    responseState: yupStringSchema,
    link: yupStringSchema,
    notes: yupStringSchema_optional,
    positions: yup.array(),
    tags: yup.array(),
    data: yup.mixed().nullable(),
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
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? "/api/cases" : `/api/cases/${selectedItem!._id}`,
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
      mutate("/api/cases");
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
              ? `פרטים של ${selectedItem.case}`
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
          <AppSelectWithController
            isViewMode={isViewMode}
            errors={errors}
            required
            label="מצב מקרה"
            fieldKey="responseState"
            control={control}
          >
            {[
              { label: "מקרים ותגובות לפני משחק", value: "before" },
              { label: "מקרים ותגובות לזמן משחק", value: "inTime" },
              { label: "מקרים ותגובות לאחרי משחק", value: "after" },
            ].map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          <AppAutoCompleteMultiSelectWithController
            isViewMode={isViewMode}
            label="עמדות"
            control={control}
            fieldKey="positions"
            options={POSITIONS}
            errors={errors}
          />

          <AppFormTextField
            register={register}
            errors={errors}
            fieldKey="case"
            label={"מקרה"}
            isViewMode={isViewMode}
          />
          <AppFormTextField
            register={register}
            errors={errors}
            fieldKey="response"
            label={"תגובה"}
            isViewMode={isViewMode}
          />
          <AppAutoCompleteMultiSelectWithController
            isViewMode={isViewMode}
            label="תגיות"
            control={control}
            fieldKey="tags"
            options={general?.tags || []}
            errors={errors}
          />
          <AppFormTextField
            register={register}
            errors={errors}
            fieldKey="link"
            label={"קישור"}
            isViewMode={isViewMode}
          />
          <AppTextArea
            register={register}
            fieldKey="notes"
            isViewMode={isViewMode}
            label="הערות"
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

export default CaseAndResponseDialog;
