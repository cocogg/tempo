<?xml version="1.0" encoding="Windows-31J"?>
<jsp:root
xmlns:jsp="http://java.sun.com/JSP/Page"
xmlns:c="http://java.sun.com/jstl/core_rt"
version="1.2">
	<taskdata>

	<jsp:text>
	<![CDATA[
    <table width="600"  cellspacing="0" cellpadding="0" id="properties_content">
        <tr id="headertr">
          <td width="13%"><strong>Task State</strong></td>
          <td width="55%"><strong>Description</strong></td>
          <td width="32%"><strong>Creation Date/Time</strong></td>
        </tr>
	]]>
    </jsp:text>

	<jsp:text>
			<c:forEach items="${activityTasks}" var="taskHolder" varStatus="status">
        	<c:choose>
        		<c:when test="${(status.index%2) == 0}">
			<![CDATA[
					<tr class="oddTr">
			]]>
        		</c:when>
        		<c:otherwise>
			<![CDATA[
					<tr class="evenTr">
			]]>
        		</c:otherwise>
        	</c:choose>

			<![CDATA[
					<td>
						<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}&user=${currentUser}" target="taskform"  >${taskHolder.task.state.name}</a>
					</td>
					<td>
						<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}&user=${currentUser}" target="taskform"  >${taskHolder.task.description}</a>
					</td>
					<td>
						<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}&user=${currentUser}" target="taskform"  >${taskHolder.task.creationDate}</a>
					</td>
				</tr>
			]]>
			</c:forEach>
		</jsp:text>

	<jsp:text>
	<![CDATA[
	</table>
	]]>
	</jsp:text>

	</taskdata>

<notificationdata>


	<jsp:text>
	<![CDATA[
    <table width="600"  cellspacing="0" cellpadding="0" id="properties_content">
        <tr id="headertr">
          <td width="65%"><strong>Description</strong></td>
          <td width="35%"><strong>Creation Date/Time</strong></td>
        </tr>
	]]>
    </jsp:text>

	<jsp:text>
		<c:forEach items="${notifications}" var="taskHolder" varStatus="status">
    	<c:choose>
    		<c:when test="${(status.index%2) == 0}">
		<![CDATA[
				<tr class="oddTr">
		]]>
    		</c:when>
    		<c:otherwise>
		<![CDATA[
				<tr class="evenTr">
		]]>
    		</c:otherwise>
    	</c:choose>

		<![CDATA[
				<td>
					<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}" target="taskform"  >${taskHolder.task.description}</a>
				</td>
				<td>
					<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}" target="taskform"  >${taskHolder.task.creationDate}</a>
				</td>
			</tr>
		]]>
		</c:forEach>
	</jsp:text>

	<jsp:text>
	<![CDATA[
	</table>
	]]>
	</jsp:text>

</notificationdata>

<processdata>

	<jsp:text>
	<![CDATA[
    <table width="600"  cellspacing="0" cellpadding="0" id="properties_content">
        <tr id="headertr">
          <td width="65%"><strong>Description</strong></td>
          <td width="35%"><strong>Creation Date/Time</strong></td>
        </tr>
	]]>
    </jsp:text>

	<jsp:text>
		<c:forEach items="${initTasks}" var="taskHolder" varStatus="status">
    	<c:choose>
    		<c:when test="${(status.index%2) == 0}">
		<![CDATA[
				<tr class="oddTr">
		]]>
    		</c:when>
    		<c:otherwise>
		<![CDATA[
				<tr class="evenTr">
		]]>
    		</c:otherwise>
    	</c:choose>

		<![CDATA[
				<td>
					<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}&user=${currentUser}" target="taskform"  >${taskHolder.task.description}</a>
				</td>
				<td>
					<a href="${taskHolder.formManagerURL}?id=${taskHolder.task.ID}&url=${taskHolder.task.formURL}&token=${participantToken}&user=${currentUser}" target="taskform"  >${taskHolder.task.creationDate}</a>
				</td>
			</tr>
		]]>
		</c:forEach>
	</jsp:text>

	<jsp:text>
	<![CDATA[
	</table>
	]]>
	</jsp:text>


</processdata>
</jsp:root>
