using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace KiemTraGiuaKy.Toeic;

[Table("ToeicAnswerChoices")]
public class ToeicAnswerChoice : FullAuditedEntity<int>
{
    public int QuestionId { get; set; }

    [ForeignKey(nameof(QuestionId))]
    public virtual ToeicQuestion Question { get; set; }

    [Required]
    [MaxLength(10)]
    public string ChoiceKey { get; set; } // A, B, C, D

    [Required]
    [MaxLength(500)]
    public string Content { get; set; }

    public bool IsCorrect { get; set; } = false;
}
