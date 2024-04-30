CREATE TABLE employees(
	emp_no INT NOT NULL,
	empt_title_id VARCHAR (6),
	birth_date DATE,
	first_name VARCHAR (20),
	last_name VARCHAR (20),
	sex VARCHAR(1),
	hire_date DATE,
	PRIMARY KEY (emp_no)
);

CREATE TABLE salaries(
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	PRIMARY KEY (emp_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
);

CREATE TABLE departments(
	dept_no VARCHAR (4) NOT NULL,
	dept_name VARCHAR (20) NOT NULL,
	PRIMARY KEY (dept_no)
);

CREATE TABLE dept_emp(
	emp_no INT NOT NULL,
	dept_no VARCHAR (4) NOT NULL,
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (emp_no) REFERENCES salaries(emp_no)
);

CREATE TABLE dept_manager(
	dept_no VARCHAR (4) NOT NULL,
	emp_no INT NOT NULL,
	PRIMARY KEY (dept_no, emp_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (emp_no) REFERENCES salaries(emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no)
);

CREATE TABLE titles(
	title_id VARCHAR (5) NOT NULL,
	title VARCHAR (20) NOT NULL,
	PRIMARY KEY (title_id)
);


--


-- List the employee number, last name, first name, sex, and salary of each employee (2 points)
CREATE VIEW employee_info_salary AS
SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary 
FROM employees e
LEFT JOIN salaries S
ON (e.emp_no = s.emp_no);

-- List the first name, last name, and hire date for the employees who were hired in 1986 (2 points)
CREATE VIEW hired_1986 AS
SELECT first_name, last_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date)=1986;

-- List the manager of each department along with their department number, department name, employee number, last name, and first name (2 points)
CREATE VIEW dept_manager_employee AS
SELECT d.dept_no, d.dept_name, e.emp_no, e.last_name, e.first_name
FROM employees e
JOIN dept_emp de ON (e.emp_no = de.emp_no)
JOIN departments d ON (de.dept_no = d.dept_no)
WHERE e.emp_no IN
(SELECT dm.emp_no FROM dept_manager dm);

-- List the department number for each employee along with that employee’s employee number, last name, first name, and department name (2 points)
CREATE VIEW employee_department_number AS
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON (e.emp_no = de.emp_no)
JOIN departments d ON (de.dept_no = d.dept_no)

-- List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B (2 points)
CREATE VIEW Hercules_B_Employees AS
SELECT first_name, last_name, sex
FROM employees
WHERE first_name = 'Hercules' AND
last_name ILIKE 'B%';

-- List each employee in the Sales department, including their employee number, last name, and first name (2 points)
CREATE VIEW sales_employees AS
SELECT emp_no, last_name, first_name
FROM employees
WHERE emp_no IN
	(SELECT emp_no
	FROM dept_emp
	WHERE dept_no IN
		(SELECT dept_no
		FROM departments
		WHERE dept_name = 'Sales'));
		
--WITH STATEMENT (IS A LITTLE SLOWER BUT EASIER TO RUN THROUGH LOGIC)
--CTE
--https://www.postgresql.org/docs/current/queries-with.html
WITH sales_dep_no AS (
	SELECT dept_no
	FROM departments
	WHERE dept_name = 'Sales'
),
sales_emp_nos AS(
	SELECT emp_no
	FROM dept_emp
	WHERE dept_no IN (SELECT dept_no FROM sales_dep_no)
)
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (SELECT emp_no FROM sales_emp_nos);

		
-- List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name (4 points)
CREATE VIEW sales_development_employees AS
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
WHERE d.dept_name IN ('Sales', 'Development');

-- List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name) (4 points)
CREATE VIEW employee_last_names_count AS
SELECT last_name, COUNT(*) AS employee_count
FROM employees
GROUP BY last_name
ORDER BY employee_count DESC;