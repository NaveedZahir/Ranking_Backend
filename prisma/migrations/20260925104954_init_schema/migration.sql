-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'USER', 'VIEWER');

-- CreateEnum
CREATE TYPE "EntityType" AS ENUM ('STUDENT', 'EMPLOYEE', 'ATHLETE', 'PRODUCT', 'CUSTOM');

-- CreateEnum
CREATE TYPE "TieBreakerStrategy" AS ENUM ('DENSE', 'STANDARD_COMPETITION');

-- CreateEnum
CREATE TYPE "ImportStatus" AS ENUM ('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_projects" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "entityType" "EntityType" NOT NULL DEFAULT 'CUSTOM',
    "tieBreakerStrategy" "TieBreakerStrategy" NOT NULL DEFAULT 'DENSE',
    "ownerId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ranking_projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_criteria" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "weight" DECIMAL(5,4) NOT NULL,
    "minValue" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "maxValue" DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    "isHigherBetter" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ranking_criteria_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_periods" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "isLocked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ranking_periods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "participants" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "participants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "participant_scores" (
    "id" TEXT NOT NULL,
    "participantId" TEXT NOT NULL,
    "criteriaId" TEXT NOT NULL,
    "rawValue" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "participant_scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ranking_results" (
    "id" TEXT NOT NULL,
    "periodId" TEXT NOT NULL,
    "participantId" TEXT NOT NULL,
    "compositeScore" DOUBLE PRECISION NOT NULL,
    "rank" INTEGER NOT NULL,
    "breakdownJson" JSONB NOT NULL,
    "calculatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ranking_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "data_imports" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "status" "ImportStatus" NOT NULL DEFAULT 'PENDING',
    "totalRows" INTEGER NOT NULL DEFAULT 0,
    "errorLog" JSONB,
    "importedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "data_imports_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "ranking_projects_ownerId_idx" ON "ranking_projects"("ownerId");

-- CreateIndex
CREATE INDEX "ranking_criteria_projectId_idx" ON "ranking_criteria"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "ranking_criteria_projectId_code_key" ON "ranking_criteria"("projectId", "code");

-- CreateIndex
CREATE INDEX "ranking_periods_projectId_idx" ON "ranking_periods"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "ranking_periods_projectId_label_key" ON "ranking_periods"("projectId", "label");

-- CreateIndex
CREATE INDEX "participants_projectId_idx" ON "participants"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "participants_projectId_externalId_key" ON "participants"("projectId", "externalId");

-- CreateIndex
CREATE INDEX "participant_scores_participantId_idx" ON "participant_scores"("participantId");

-- CreateIndex
CREATE INDEX "participant_scores_criteriaId_idx" ON "participant_scores"("criteriaId");

-- CreateIndex
CREATE UNIQUE INDEX "participant_scores_participantId_criteriaId_key" ON "participant_scores"("participantId", "criteriaId");

-- CreateIndex
CREATE INDEX "ranking_results_periodId_rank_idx" ON "ranking_results"("periodId", "rank");

-- CreateIndex
CREATE INDEX "ranking_results_participantId_idx" ON "ranking_results"("participantId");

-- CreateIndex
CREATE UNIQUE INDEX "ranking_results_periodId_participantId_key" ON "ranking_results"("periodId", "participantId");

-- CreateIndex
CREATE INDEX "data_imports_projectId_idx" ON "data_imports"("projectId");

-- AddForeignKey
ALTER TABLE "ranking_projects" ADD CONSTRAINT "ranking_projects_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_criteria" ADD CONSTRAINT "ranking_criteria_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "ranking_projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_periods" ADD CONSTRAINT "ranking_periods_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "ranking_projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participants" ADD CONSTRAINT "participants_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "ranking_projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participant_scores" ADD CONSTRAINT "participant_scores_participantId_fkey" FOREIGN KEY ("participantId") REFERENCES "participants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participant_scores" ADD CONSTRAINT "participant_scores_criteriaId_fkey" FOREIGN KEY ("criteriaId") REFERENCES "ranking_criteria"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_results" ADD CONSTRAINT "ranking_results_periodId_fkey" FOREIGN KEY ("periodId") REFERENCES "ranking_periods"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ranking_results" ADD CONSTRAINT "ranking_results_participantId_fkey" FOREIGN KEY ("participantId") REFERENCES "participants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_imports" ADD CONSTRAINT "data_imports_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "ranking_projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;
