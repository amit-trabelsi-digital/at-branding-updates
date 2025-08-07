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
  yupNumberSchema_optional,
  yupStringSchema,
  yupStringSchema_optional,
} from "../../utils/validators";

import EditIcon from "@mui/icons-material/Edit";
import { enqueueSnackbar } from "notistack";
import { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, Score } from "../../utils/types";
import AppSelectWithController from "../general/AppSelectWithController";
import { SCORE_BRANCH_LIST, SCORE_TRIGGER_LIST } from "../../data/lists";
import AppFormTextField from "../general/AppFormTextField";
import AppDialog from "../general/AppDialog";
import AppTextArea from "../general/AppTextArea";

type Props = BaseDialogProps & { selectedItem: Score | null };

function ScoreDialog({ open, onClose, selectedItem }: Props) {
  // const { data } = useSWR<Score[]>("/api/scores");

  const [loading, setLoading] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;

  const objectSchema = {
    scoreTrigger: yupStringSchema,
    points: yupStringSchema,
    notes: yupStringSchema_optional,
    limit: yupNumberSchema_optional,
    branch: yupStringSchema,
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
        console.log(value);
        setValue(_key, value as string);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedItem]);

  const onSubmit = handleSubmit(async (data) => {
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? "/api/scores" : `/api/scores/${selectedItem!._id}`,
        {
          method: isCreationMode ? "POST" : "PUT",
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) throw new Error();
      enqueueSnackbar(isEditMode ? "השינויים נשמרו" : `ליגה חדש נוצר`);
      onCloseHandler();
      mutate("/api/scores");
    } catch (error) {
      console.error(error);
      enqueueSnackbar(`שגיאה`, {
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
          {/* <AppSubtitle>פרטי ליגה</AppSubtitle> */}

          <AppSelectWithController
            isViewMode={isViewMode}
            errors={errors}
            required
            label="פעולה"
            fieldKey="scoreTrigger"
            control={control}
          >
            {SCORE_TRIGGER_LIST.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="points"
            label={"ניקוד"}
            type="number"
          />
          <AppSelectWithController
            isViewMode={isViewMode}
            errors={errors}
            required
            label="משפחות"
            fieldKey="branch"
            control={control}
          >
            {SCORE_BRANCH_LIST.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>

          <AppTextArea
            errors={errors}
            fieldKey={"notes"}
            register={register}
            isViewMode={isViewMode}
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

export default ScoreDialog;
