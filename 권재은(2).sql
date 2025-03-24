-- 1. 부서코드가 노옹철 사원과 같은 소속의 직원 명단 조회하세요.
select *
from employee
where dept_code = (
select dept_code
from employee
where emp_name = '노옹철'
);

-- 2. 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원의 사번, 이름, 직급코드, 급여를 조회하세요.
select emp_id, emp_name, job_code, salary
from employee
where salary > (
select avg(salary)
from employee
);

-- 3. 노옹철 사원의 급여보다 많이 받는 직원의 사번, 이름, 부서코드, 직급코드, 급여를 조회하세요.
select emp_id, emp_name, dept_code, job_code, salary
from employee
where salary > (
select salary
from employee
where emp_name ='노옹철'
);

-- 4. 가장 적은 급여를 받는 직원의 사번, 이름, 부서코드, 직급코드, 급여, 입사일을 조회하세요.
select emp_id, emp_name, dept_code, job_code, salary, hire_date
from employee
where salary = (
select min(salary)
from employee
);

-- *** 서브쿼리는 SELECT, FROM, WHERE, HAVING, ORDER BY절에도 사용할 수 있다.

-- 5. 부서별 최고 급여를 받는 직원의 이름, 직급코드, 부서코드, 급여 조회하세요.
select emp_name, job_code, dept_code, salary
from employee e
where salary = (
select max(salary)
from employee
where dept_code <=> e.dept_code  -- (부서 = 각 부서별로 라는 뜻), <=> 이건 null 도 포함시킨다는 =
);

-- *** 여기서부터 난이도 극상

-- 6. 관리자에 해당하는 직원에 대한 정보와 관리자가 아닌 직원의 정보를 추출하여 조회하세요.
-- 사번, 이름, 부서명, 직급, '관리자' AS 구분 / '직원' AS 구분
-- HINT!! is not null, union(혹은 then, else), distinct

select distinct e.emp_id, e.emp_name, d.dept_title, j.job_name, '관리자' as 구분
from employee e 
join department d on e.dept_code = d.dept_id
join job j on e.job_code = j.job_code
where e.emp_id in (   -- where 컬럼명 in(값1, 값2, ...), 컬럼명이 괄호 안에 있는 값 중 하나와 일치하는지 확인하는 조건문
select manager_id
from employee
where manager_id is not null 
)    -- order by는 서브쿼리 안에서 못 씀

union  -- 값 합치고 중복 제거

select e.emp_id, e.emp_name, d.dept_title, j.job_name, '직원' as 구분
from employee e
left join department d on e.dept_code = d.dept_id    -- select ~ join a left join a.컬럼 = b.컬럼 에서 왼쪽 테이블 a의 모든 행은 다 유지하면서, 오른쪽 테이블 b와 일치하는 값이 있으면 붙이고 없으면 null로 채움
join job j on e.job_code = j.job_code
where e.emp_id not in (
select manager_id
from employee
where manager_id is not null   -- where 는 항상 from 뒤에 와야 함
)
order by emp_id;


-- 7. 자기 직급의 평균 급여를 받고 있는 직원의 사번, 이름, 직급코드, 급여를 조회하세요.
-- 단, 급여와 급여 평균은 만원단위로 계산하세요.
-- HINT!! round(컬럼명, -5)

select a.emp_id, a.emp_name, a.job_code, round(a.salary,-4)
from employee a
where round(a.salary, -4) = (   -- round( int형 컬럼명, -4) 1만 단위로 반올림한다, -5는 10만단위!, 그냥 round 는 소수를 정수로 반올림
select round(avg(b.salary), -4)   
from employee b
where a.job_code = b.job_code  -- 자기 자신 비교, 이 문장 아예 사라지면 전체와 평균급여 비교이고, WHERE job_code 이렇게만 쓰면 비교할 게 없어져 문법 오류
);

-- 8. 퇴사한 여직원과 같은 부서, 같은 직급에 해당하는 직원의 이름, 직급코드, 부서코드, 입사일을 조회하세요.
select emp_name, job_code, hire_date
from employee
where (dept_code, job_code) in ( -- in 대신에 = 쓰면 서브쿼리가 하나의 결과값만 반환하는게 아니라 dept_code, job_cdoe 2개를 반환해야 하므로 오류 
select dept_code, job_code
from employee
where emp_no like '7_____-2______' and ent_yn = 'Y'
)
and ent_yn = 'N';

-- 9. 급여 평균 3위 안에 드는 부서의 부서 코드와 부서명, 평균급여를 조회하세요.
-- HINT!! limit
select d.dept_id, d.dept_title, avg(e.salary) as avg_salary
from employee e
join department d on e.dept_code = d.dept_id
group by d.dept_id, d.dept_title  -- 이 뒤에 ,avg_salary 넣은면 오류남(select 보다 group by가 먼저 실행됨, 처음 실행하면 avg_salary는 없는 값, 그리고 group by에는 집계 대상이 아닌 컬럼들만 넣어야 함,salary넣으면 부서별 평균이 아니라 사원별 급여로 나누게 됨
order by avg_salary desc
limit 3;

-- 10. 부서별 급여 합계가 전체 급여의 총 합의 20%보다 많은 부서의 부서명과, 부서별 급여 합계를 조회하세요.
select d.dept_title, sum(e.salary) as total_salary
from employee e
join department d on e.dept_code = d.dept_id
group by d.dept_title
having sum(e.salary) > (  -- having은 group을 집계함수(avt,sum 등)로 조건을 걸 때 사용함
select sum(salary) * 0.2
from employee
);