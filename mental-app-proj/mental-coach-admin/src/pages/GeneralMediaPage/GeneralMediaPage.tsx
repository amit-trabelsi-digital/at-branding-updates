import React, { useState } from "react";
import {
  ref,
  uploadBytesResumable,
  getDownloadURL,
  getStorage,
} from "firebase/storage";
import useSWR from "swr";
import {
  Button,
  CircularProgress,
  Typography,
  Box,
  Paper,
} from "@mui/material";
import { app } from "../../utils/firebase";
// import { appFetch } from "../../services/fetch";
import profilePageImage from "./../../assets/media/profile-image.png";
import goalsPageImage from "./../../assets/media/goals-image.png";
import { appFetch } from "../../services/fetch";
import { isAudioFile } from "../../utils/tools";
import { enqueueSnackbar } from "notistack";

// SWR fetcher function

export default function GeneralMediaPage() {
  // State for file uploads
  const [profileAudioFile, setProfileAudioFile] = useState<File | null>(null);
  const [goalsAudioFile, setGoalsAudioFile] = useState<File | null>(null);
  const [uploading1, setUploading1] = useState(false);
  const [uploading2, setUploading2] = useState(false);

  // Use SWR for fetching data
  const { data, error, mutate } = useSWR("/api/general");

  // Extract file info from SWR data
  const fileInfo1 = data?.profileAudioFile?.fileData || null;
  const fileInfo2 = data?.goalsAudioFile?.fileData || null;

  const handleFileChange = (
    e: React.ChangeEvent<HTMLInputElement>,
    fileType: "profileAudioFile" | "goalsAudioFile"
  ) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];

      if (fileType === "goalsAudioFile" || fileType === "profileAudioFile") {
        if (!isAudioFile(file)) {
          enqueueSnackbar("נא לבחור קובץ שמע בלבד", {
            variant: "error",
          });
          return;
        }

        if (fileType === "profileAudioFile") {
          setProfileAudioFile(file);
        } else {
          setGoalsAudioFile(file);
        }
      }
    }
  };

  const uploadFile = async (
    file: File,
    fileType: "profileAudioFile" | "goalsAudioFile"
  ) => {
    if (!file) return;

    const setUploading =
      fileType === "profileAudioFile" ? setUploading1 : setUploading2;

    setUploading(true);

    try {
      const storage = getStorage(app);

      // Create a reference to Firebase Storage
      const storageRef = ref(storage, `/audio/${fileType}-${file.name}`);

      // Upload file
      const uploadTask = uploadBytesResumable(storageRef, file);

      // Wait for upload to complete
      await new Promise<void>((resolve, reject) => {
        uploadTask.on(
          "state_changed",
          (snapshot) => {
            console.log(snapshot.bytesTransferred, snapshot.totalBytes);
            // Optional: Add progress tracking here
          },
          (error) => {
            console.error("Upload error:", error);
            reject(error);
          },
          () => {
            resolve();
          }
        );
      });

      // Get download URL
      const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);

      // Save to MongoDB

      console.log(downloadURL);

      const fileData = {
        name: file.name,
        path: downloadURL,
      };

      appFetch("/api/general", {
        method: "PUT",
        body: JSON.stringify({
          fileType,
          fileData,
        }),
      });

      // Revalidate the data after upload
      mutate();
    } catch (error) {
      console.error("Error uploading file:", error);
    } finally {
      enqueueSnackbar("הקובץ הועלה בהצלחה", {
        variant: "success",
      });
      setUploading(false);
    }
  };

  return (
    <Box p={3}>
      <Typography variant="h1" gutterBottom>
        קובצי מדיה כללי לאפליקציה
      </Typography>

      {error && (
        <Typography color="error" gutterBottom>
          שגיאה בטעינת נתונים: {error.message}
        </Typography>
      )}

      {!data && !error && (
        <Box display="flex" justifyContent="center" my={4}>
          <CircularProgress />
        </Box>
      )}

      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          קובץ שמע לדף פרופיל
        </Typography>
        <Box margin={2}>
          <img
            src={profilePageImage}
            alt="Profile Audio page"
            style={{ width: 70, height: 70 }}
          />
        </Box>
        {fileInfo1 && (
          <Box mb={2}>
            <Typography>
              קובץ נוכחי: <a href={fileInfo1.path}>{fileInfo1.name}</a>
            </Typography>
          </Box>
        )}

        <Box display="flex" alignItems="center" gap={2}>
          <Button variant="contained" component="label">
            בחר קובץ
            <input
              type="file"
              hidden
              onChange={(e) => handleFileChange(e, "profileAudioFile")}
            />
          </Button>

          {profileAudioFile && (
            <Typography> {profileAudioFile.name}</Typography>
          )}

          <Button
            variant="contained"
            color="primary"
            disabled={!profileAudioFile || uploading1}
            onClick={() =>
              profileAudioFile &&
              uploadFile(profileAudioFile, "profileAudioFile")
            }
          >
            {uploading1 ? <CircularProgress size={24} /> : "העלאת קובץ"}
          </Button>
        </Box>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          קובץ שמע לדף פרופיל ומטרות
        </Typography>

        <Box margin={2}>
          <img
            src={goalsPageImage}
            alt="Profile Audio page"
            style={{ width: 70, height: 70 }}
          />
        </Box>
        {fileInfo2 && (
          <Box mb={2}>
            <Typography>
              קובץ נוכחי: <a href={fileInfo2.path}>{fileInfo2.name}</a>
            </Typography>
          </Box>
        )}

        <Box display="flex" alignItems="center" gap={2}>
          <Button variant="contained" component="label">
            בחר קובץ
            <input
              type="file"
              hidden
              onChange={(e) => handleFileChange(e, "goalsAudioFile")}
            />
          </Button>

          {goalsAudioFile && (
            <Typography>Selected: {goalsAudioFile.name}</Typography>
          )}

          <Button
            variant="contained"
            color="primary"
            disabled={!goalsAudioFile || uploading2}
            onClick={() =>
              goalsAudioFile && uploadFile(goalsAudioFile, "goalsAudioFile")
            }
          >
            {uploading2 ? <CircularProgress size={24} /> : "העלה קובץ"}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}
