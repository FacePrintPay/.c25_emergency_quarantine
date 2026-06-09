CREATE TABLE `agentLogs` (
	`id` int AUTO_INCREMENT NOT NULL,
	`buildId` int NOT NULL,
	`phase` enum('earth','moon','sun') NOT NULL,
	`agentId` varchar(255) NOT NULL,
	`status` enum('running','completed','failed') NOT NULL,
	`input` text,
	`output` text,
	`errorMessage` text,
	`executionTimeMs` int,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `agentLogs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `analyticsEvents` (
	`id` bigint AUTO_INCREMENT NOT NULL,
	`userId` int,
	`eventType` varchar(255) NOT NULL,
	`eventData` json,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `analyticsEvents_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `builds` (
	`id` int AUTO_INCREMENT NOT NULL,
	`artifactId` varchar(255) NOT NULL,
	`userId` int NOT NULL,
	`inputType` enum('prompt','artifact') NOT NULL,
	`inputContent` text NOT NULL,
	`status` enum('pending','scaffolding','validating','optimizing','compiling','pushing','deploying','completed','failed') NOT NULL DEFAULT 'pending',
	`errorMessage` text,
	`githubRepoUrl` varchar(500),
	`vercelUrl` varchar(500),
	`vercelDeploymentId` varchar(255),
	`generatedCode` text,
	`agentMetadata` json,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	`completedAt` timestamp,
	CONSTRAINT `builds_id` PRIMARY KEY(`id`),
	CONSTRAINT `builds_artifactId_unique` UNIQUE(`artifactId`)
);
--> statement-breakpoint
CREATE TABLE `oauthTokens` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`provider` enum('github','vercel') NOT NULL,
	`accessToken` text NOT NULL,
	`refreshToken` text,
	`expiresAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `oauthTokens_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `payments` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`stripePaymentIntentId` varchar(255),
	`amount` decimal(10,2) NOT NULL,
	`currency` varchar(3) NOT NULL DEFAULT 'USD',
	`status` enum('pending','succeeded','failed','refunded') NOT NULL,
	`description` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `payments_id` PRIMARY KEY(`id`),
	CONSTRAINT `payments_stripePaymentIntentId_unique` UNIQUE(`stripePaymentIntentId`)
);
--> statement-breakpoint
CREATE TABLE `platformMetrics` (
	`id` int AUTO_INCREMENT NOT NULL,
	`date` timestamp NOT NULL,
	`totalUsers` int NOT NULL DEFAULT 0,
	`activeUsers` int NOT NULL DEFAULT 0,
	`totalBuilds` int NOT NULL DEFAULT 0,
	`successfulBuilds` int NOT NULL DEFAULT 0,
	`failedBuilds` int NOT NULL DEFAULT 0,
	`totalRevenue` decimal(12,2) DEFAULT '0',
	`conversionRate` decimal(5,2) DEFAULT '0',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `platformMetrics_id` PRIMARY KEY(`id`),
	CONSTRAINT `platformMetrics_date_unique` UNIQUE(`date`)
);
--> statement-breakpoint
CREATE TABLE `subscriptionPlans` (
	`id` int AUTO_INCREMENT NOT NULL,
	`tier` enum('free','pro','enterprise') NOT NULL,
	`name` varchar(255) NOT NULL,
	`description` text,
	`monthlyPrice` decimal(10,2),
	`annualPrice` decimal(10,2),
	`powerUpsPerMonth` int,
	`features` json,
	`stripePriceId` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `subscriptionPlans_id` PRIMARY KEY(`id`),
	CONSTRAINT `subscriptionPlans_tier_unique` UNIQUE(`tier`)
);
--> statement-breakpoint
ALTER TABLE `users` ADD `subscriptionTier` enum('free','pro','enterprise') DEFAULT 'free' NOT NULL;--> statement-breakpoint
ALTER TABLE `users` ADD `stripeCustomerId` varchar(255);--> statement-breakpoint
ALTER TABLE `users` ADD `stripeSubscriptionId` varchar(255);--> statement-breakpoint
ALTER TABLE `users` ADD `powerUpsUsedThisMonth` int DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE `users` ADD `powerUpsLimit` int DEFAULT 3 NOT NULL;--> statement-breakpoint
ALTER TABLE `users` ADD CONSTRAINT `users_email_unique` UNIQUE(`email`);--> statement-breakpoint
ALTER TABLE `agentLogs` ADD CONSTRAINT `agentLogs_buildId_builds_id_fk` FOREIGN KEY (`buildId`) REFERENCES `builds`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `analyticsEvents` ADD CONSTRAINT `analyticsEvents_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `builds` ADD CONSTRAINT `builds_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `oauthTokens` ADD CONSTRAINT `oauthTokens_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `payments` ADD CONSTRAINT `payments_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `build_idx` ON `agentLogs` (`buildId`);--> statement-breakpoint
CREATE INDEX `phase_idx` ON `agentLogs` (`phase`);--> statement-breakpoint
CREATE INDEX `user_idx` ON `analyticsEvents` (`userId`);--> statement-breakpoint
CREATE INDEX `eventType_idx` ON `analyticsEvents` (`eventType`);--> statement-breakpoint
CREATE INDEX `createdAt_idx` ON `analyticsEvents` (`createdAt`);--> statement-breakpoint
CREATE INDEX `user_idx` ON `builds` (`userId`);--> statement-breakpoint
CREATE INDEX `status_idx` ON `builds` (`status`);--> statement-breakpoint
CREATE INDEX `artifactId_idx` ON `builds` (`artifactId`);--> statement-breakpoint
CREATE INDEX `user_provider_idx` ON `oauthTokens` (`userId`,`provider`);--> statement-breakpoint
CREATE INDEX `user_idx` ON `payments` (`userId`);--> statement-breakpoint
CREATE INDEX `status_idx` ON `payments` (`status`);--> statement-breakpoint
CREATE INDEX `date_idx` ON `platformMetrics` (`date`);--> statement-breakpoint
CREATE INDEX `email_idx` ON `users` (`email`);--> statement-breakpoint
CREATE INDEX `openId_idx` ON `users` (`openId`);