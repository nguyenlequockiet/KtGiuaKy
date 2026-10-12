using Abp.Zero.EntityFrameworkCore;
using KiemTraGiuaKy.Authorization.Roles;
using KiemTraGiuaKy.Authorization.Users;
using KiemTraGiuaKy.MultiTenancy;
using KiemTraGiuaKy.Toeic;
using Microsoft.EntityFrameworkCore;

namespace KiemTraGiuaKy.EntityFrameworkCore;

public class KiemTraGiuaKyDbContext : AbpZeroDbContext<Tenant, Role, User, KiemTraGiuaKyDbContext>
{
    /* Define a DbSet for each entity of the application */
    public virtual DbSet<ToeicExam> ToeicExams { get; set; }
    public virtual DbSet<ToeicPassage> ToeicPassages { get; set; }
    public virtual DbSet<ToeicQuestion> ToeicQuestions { get; set; }
    public virtual DbSet<ToeicAnswerChoice> ToeicAnswerChoices { get; set; }
    public virtual DbSet<ToeicExamResult> ToeicExamResults { get; set; }

    public KiemTraGiuaKyDbContext(DbContextOptions<KiemTraGiuaKyDbContext> options)
        : base(options)
    {
    }
}
