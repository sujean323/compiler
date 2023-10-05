; === prologue ====
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 0, i32* %t1
%t2=load i32, i32* %t1
%t3 = add nsw i32 %t2, 100
%t4 = add nsw i32 %t3, 123
store i32 %t4, i32* %t0

; === epilogue ===
ret i32 0
}
