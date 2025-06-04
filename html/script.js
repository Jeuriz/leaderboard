window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openLeaderboard':
            showLeaderboard(data.leaderboard);
            break;
        case 'closeLeaderboard':
            hideLeaderboard();
            break;
        case 'updateLeaderboard':
            updateLeaderboard(data.leaderboard);
            break;
    }
});

function showLeaderboard(leaderboard) {
    document.body.style.display = 'flex';
    updateLeaderboard(leaderboard);
}

function hideLeaderboard() {
    document.body.style.display = 'none';
}

function updateLeaderboard(leaderboard) {
    const tbody = document.getElementById('leaderboard-body');
    tbody.innerHTML = '';
    
    leaderboard.forEach((player, index) => {
        const rank = index + 1;
        const row = document.createElement('tr');
        
        // Agregar clases según el ranking
        row.classList.add('player-row');
        if (rank === 1) row.classList.add('rank-1');
        if (rank <= 3) row.classList.add('top-3');
        
        row.innerHTML = `
            <td class="rank-cell">
                <span class="position-indicator">${rank}</span>
            </td>
            <td class="icon-cell">${player.icon}</td>
            <td class="player-name">${player.name}</td>
            <td class="zombie-kills">${player.kills.toLocaleString()}</td>
        `;
        
        tbody.appendChild(row);
    });
}

function closeLeaderboard() {
    fetch(`https://${GetParentResourceName()}/closeLeaderboard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

// Cerrar con tecla ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeLeaderboard();
    }
});
