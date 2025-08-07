/* eslint-disable @typescript-eslint/no-explicit-any */
import { yupResolver } from "@hookform/resolvers/yup";
import { useForm } from "react-hook-form";
import {
  // yupStringSchema,
  yupStringSchema_optional,
} from "../../utils/validators";
import * as yup from "yup";
import { Box, Chip, Stack } from "@mui/material";
import AppSubtitle from "../../components/general/AppSubtitle";
import AppFormTextField from "../../components/general/AppFormTextField";
import { enqueueSnackbar } from "notistack";
import useSWR, { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { useState } from "react";
import { LoadingButton } from "@mui/lab";
import AppTitle from "../../components/general/AppTitle";

export default function TagsPage() {
  const objectSchema = {
    tag: yupStringSchema_optional,
    personallityTag: yupStringSchema_optional,
  };
  const schema = yup.object().shape(objectSchema);

  const { data } = useSWR("/api/general");

  const {
    register,
    formState: { errors },
    reset,
    handleSubmit,
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: schema.getDefault(),
  });

  const [loading, setLoading] = useState(false);

  const handleGenericSubmit = async (urlExtend: string, data: any) => {
    try {
      const res = await appFetch(`/api/general${urlExtend}`, {
        method: "POST",
        body: JSON.stringify(data),
      });
      if (!res.ok) {
        const error = await res.json();
        throw new Error(error.message);
      }
      enqueueSnackbar(`בוצע בהצלחה`);
      mutate("/api/general");
    } catch (error: any) {
      enqueueSnackbar(error?.message || `שגיאה`, {
        variant: "error",
      });
    } finally {
      console.log("finally");
      reset({ tag: "", personallityTag: "" });
      console.log("finally");
      setLoading(false);
    }
  };

  const handleDelete = async (value: string, item: string) => {
    try {
      const res = await appFetch(
        `/api/general/removetag?item=${item}&value=${value}`,
        {
          method: "DELETE",
        }
      );
      if (!res.ok) {
        const error = await res.json();
        throw new Error(error.message);
      }
      enqueueSnackbar(`תג נמחק`);
      mutate("/api/general");
    } catch (error: any) {
      enqueueSnackbar(error?.message || `שגיאה`, {
        variant: "error",
      });
    } finally {
      reset();
      setLoading(false);
    }
  };

  const handleAddTag = async (data: { tag?: string | null | undefined }) => {
    handleGenericSubmit("", { tag: data.tag });
  };
  const handleAddPersonallityTag = async (data: {
    personallityTag?: string | null | undefined;
  }) => {
    handleGenericSubmit("", { personallityTag: data.personallityTag });
  };

  return (
    <>
      <AppTitle title={"הגדרות"} />
      <AppSubtitle>הוספת תגיות</AppSubtitle>
      <Box
        component="form"
        onSubmit={handleSubmit(handleAddTag)} // Handles form submission
        sx={{ display: "flex", flexDirection: "column", gap: 1, width: 200 }}
      >
        <AppFormTextField
          fieldKey={"tag"}
          register={register}
          errors={errors}
          label={"הוספת תגיות"}
        />

        <LoadingButton
          type="submit" // Set button type to "submit" to trigger form submission
          loading={loading}
          sx={{ bgcolor: "black", color: "white" }}
        >
          הוספה
        </LoadingButton>
      </Box>

      <Stack
        direction="row"
        spacing={1}
        sx={{ marginTop: "10px", maxWidth: "60%" }}
      >
        {data?.tags?.map((tag: { label: string; value: string }) => (
          <Chip
            key={tag.label}
            label={tag.label}
            onDelete={() => handleDelete(tag.value, "tags")}
            color="primary"
          />
        ))}
      </Stack>
      <div>
        <AppSubtitle> הוספת תגיות אופי</AppSubtitle>
        <Box
          component="form"
          onSubmit={handleSubmit(handleAddPersonallityTag)} // Handles form submission
          sx={{ display: "flex", flexDirection: "column", gap: 1, width: 200 }}
        >
          <AppFormTextField
            fieldKey={"personallityTag"}
            register={register}
            errors={errors}
            label={"הוספת תגיות"}
          />

          <LoadingButton
            type="submit" // Set button type to "submit" to trigger form submission
            loading={loading}
            sx={{ bgcolor: "black", color: "white" }}
          >
            הוספה
          </LoadingButton>
        </Box>
        <Box
          // direction="row"
          // spacing={1}
          justifyContent={"space-between"}
          flex={"wrap"}
          sx={{
            marginTop: "10px",
            width: "50%",
            minWidth: "450px",
          }}
        >
          {data?.personallityTags?.map(
            (tag: { label: string; value: string }) => (
              <Chip
                sx={{ margin: "5px" }}
                key={tag.label}
                label={tag.label}
                onDelete={() => handleDelete(tag.value, "personallityTags")}
                color="primary"
              />
            )
          )}
        </Box>
        ,
      </div>
    </>
  );
}
