import { Slide, SlideProps, Tooltip } from "@mui/material";
import { ToolTipPopsitionFullList } from "../../utils/tools";
import { Position } from "../../utils/types";
import React from "react";

export const LabelsList = (arr: Position[], maxWidth: string = "220px") => {
  return (
    <Tooltip title={ToolTipPopsitionFullList(arr)}>
      <div
        style={{
          maxWidth: maxWidth,
          overflow: "hidden",
          textOverflow: "ellipsis",
          whiteSpace: "nowrap",
        }}
      >
        {ToolTipPopsitionFullList(arr)}
      </div>
    </Tooltip>
  );
};

export const Transition = React.forwardRef(function Transition(
  props: SlideProps,
  ref
) {
  return (
    <Slide direction="left" ref={ref} {...props} children={props.children} />
  );
});

export default { LabelsList, Transition };
