package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.Date;

@Data
@TableName("adverse_reaction")
public class AdverseReaction {
    @TableId(type = IdType.AUTO)
    private Long id;
    @NotNull(message = "鑽搧ID涓嶈兘涓虹┖")
    private Long drugId;
    private String patientName;
    @NotBlank(message = "涓嶈壇鍙嶅簲鎻忚堪涓嶈兘涓虹┖")
    private String reactionDescription;
    private String severity;
    private String hospital;
    private String doctorName;
    private Long reporterId;
    private Integer status;
    private Date createdAt;
}
