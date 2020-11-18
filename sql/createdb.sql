/****** Object:  Table [dbo].[zone]    Script Date: 11/16/2020 4:40:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[zone](
	[zone_id] [int] IDENTITY(1,1),
	[zone_name] [nchar](50) NOT NULL,
	[image_url] [nchar](255) NULL,
	[schedule_id] [int] NULL,
 CONSTRAINT [PK_zone] PRIMARY KEY CLUSTERED 
(
	[zone_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO