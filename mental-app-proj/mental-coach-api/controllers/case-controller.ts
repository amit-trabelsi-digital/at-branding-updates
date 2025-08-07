import { Request, Response, NextFunction } from "express";
import Case from "../models/case-model";

// Create a caseAndResponse
export const createCase = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const caseAndResponse = new Case(req.body);
    const savedCaseAndResponse = await caseAndResponse.save();
    res.status(201).json(savedCaseAndResponse);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get all cases
export const getAllCases = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const cases = await Case.find();
    res.status(200).json(cases);
  } catch (error) {
    next(error);
  }
};

// Get a caseAndResponse by ID
export const getCaseById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const caseAndResponse = await Case.findById(id);

    if (!caseAndResponse) {
      res.status(404).json({ message: "Case not found" });
      return;
    }

    res.status(200).json(caseAndResponse);
  } catch (error) {
    next(error);
  }
};

// Update a caseAndResponse
export const updateCase = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedCase = await Case.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedCase) {
      res.status(404).json({ message: "Case not found" });
      return;
    }

    res.status(200).json(updatedCase);
  } catch (error) {
    next(error);
  }
};

// Delete a caseAndResponse
export const deleteCase = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedCase = await Case.findByIdAndDelete(id);

    if (!deletedCase) {
      res.status(404).json({ message: "Case not found" });
      return;
    }

    res.status(200).json({ message: "Case deleted successfully" });
  } catch (error) {
    next(error);
  }
};
